import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/services/reels_cache_service.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';

import '../../../app_data.dart';
import '../../../widgets/mood_selecting_scroll_wheel_widget.dart';
import '../video_feed_view/bloc_cubit/video_feed_cubit.dart';
import '../video_feed_view/bloc_cubit/video_feed_state.dart';
import '../widgets/video_feed_item.dart';
import '../../../res/app_constants.dart';
import '../../../res/app_textstyles.dart';
import '../../../services/user_service.dart';

class UpdatedFeedView extends StatefulWidget {
  const UpdatedFeedView({super.key});

  @override
  State<UpdatedFeedView> createState() => _UpdatedFeedViewState();
}

class _UpdatedFeedViewState extends State<UpdatedFeedView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  /// Maximum number of controllers to keep in cache for optimal performance
  final int _maxCacheSize = 6;

  /// The current videos to display
  List<ReelModel> _videos = [];

  /// Current visible page
  int _currentPage = 0;

  /// PageView controller for efficient preloading
  final PreloadPageController _pageController = PreloadPageController();

  /// Whether the app is currently active
  bool _isAppActive = true;

  /// LRU cache of video controllers by video ID for quick access
  final Map<String, VideoPlayerController> _controllerCache = {};

  /// Ordered list of video IDs by most recently accessed for cache management
  final List<String> _accessOrder = [];

  /// Set of video IDs currently being disposed to prevent race conditions
  final Set<String> _disposingControllers = <String>{};

  /// Flag to track if initial videos have been loaded
  bool _initialVideosLoaded = false;

  /// Flag to track if we're showing a background refresh indicator
  bool _showingBackgroundRefresh = false;

  /// Flag to track if we're currently handling a page change
  bool _isHandlingPageChange = false;

  /// Track the currently playing video ID to prevent race conditions
  String? _currentlyPlayingVideoId;

  /// Timer for delayed preloading to avoid overloading during fast scrolling
  Timer? _preloadTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      context.read<VideoFeedCubit>().initialize().then((_) {
        _initializeFirstVideo();
      });
    });

    Future.microtask(() {
      final cubit = context.read<VideoFeedCubit>();
      cubit.stream.listen((state) {
        if (state.isLoading && !state.isPaginating && state.loadingSource == 'network') {
          _handleRefresh();
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _isAppActive;
    _isAppActive = state == AppLifecycleState.resumed;

    if (_isAppActive && !wasActive) {
      _cleanupAndReinitializeCurrentVideo();
    } else if (!_isAppActive && wasActive && _currentlyPlayingVideoId != null) {
      _pauseExceptCurrent(_currentlyPlayingVideoId!);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAllControllers();
    super.dispose();
  }

  void _initializeFirstVideo() async {
    final state = context.read<VideoFeedCubit>().state;
    if (state.videos.isNotEmpty) {
      setState(() {
        _videos = state.videos;
        _initialVideosLoaded = true;
      });

      if (_videos.isNotEmpty) {
        await _getOrCreateController(_videos[0], highPriority: true);
      }

      for (int i = 1; i < math.min(3, _videos.length); i++) {
        _getOrCreateController(_videos[i], highPriority: i == 1);
      }

      if (!context.read<VideoFeedCubit>().state.shouldPauseVideo) {
        await _initAndPlayVideo(0);
      }

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _handleRefresh() {
    _disposeAllControllers();
    setState(() {
      _currentPage = 0;
      _videos = [];
      _initialVideosLoaded = false;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  Future<void> _cleanupAndReinitializeCurrentVideo() async {
    if (_videos.isEmpty || _currentPage >= _videos.length) return;
    final videoId = _videos[_currentPage].reelID;
    await _pauseExceptCurrent(videoId);
    final controller = _getController(videoId);

    if (controller != null && (controller.value.hasError || !controller.value.isInitialized)) {
      await _removeController(videoId);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await _manageControllerWindow(_currentPage);
    await _initAndPlayVideo(_currentPage);
  }

  Future<void> _initAndPlayVideo(int index) async {
    if (_videos.isEmpty || index >= _videos.length) return;

    final videoToPlay = _videos[index];
    final videoId = videoToPlay.reelID;
    _currentlyPlayingVideoId = videoId;

    // Pause and mute all controllers except the current one
    await _pauseExceptCurrent(videoId);
    VideoPlayerController? controller = await _getOrCreateController(videoToPlay, highPriority: true);

    if (controller != null && controller.value.isInitialized) {
      await controller.seekTo(Duration.zero);
      if (!videoToPlay.isMuted) {
        await controller.setVolume(1.0);
      } else {
        await controller.setVolume(0.0);
      }

      await controller.play();
      // Add a small delay to ensure play command is processed, retry if needed
      /*await Future.delayed(const Duration(milliseconds: 50));
      if (!controller.value.isPlaying) {
        await controller.play();
      }
      // One more retry after another delay to ensure playback starts
      await Future.delayed(const Duration(milliseconds: 100));
      if (!controller.value.isPlaying) {
        await controller.play();
      }*/
    }

    if (mounted) {
      setState(() {});
    }

    _preloadTimer?.cancel();
    _preloadTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<VideoFeedCubit>().preloadNextVideos();
        ReelsCacheService.getCurrentMood().then((currentMood) {
          ReelsCacheService.getCachedReels(currentMood);
        });
      }
    });
  }

  VideoPlayerController? _getController(String videoId) {
    return _controllerCache[videoId];
  }

  void _touchController(String videoId) {
    _accessOrder.remove(videoId);
    _accessOrder.add(videoId);
  }

  Future<VideoPlayerController?> _getOrCreateController(ReelModel video, {bool highPriority = false}) async {
    if (_controllerCache.containsKey(video.reelID)) {
      _touchController(video.reelID);
      return _controllerCache[video.reelID];
    }

    try {
      File? videoFile = await ReelsCacheService.getCachedVideo(video.videoUrl);
      if (videoFile == null || !await videoFile.exists()) {
        videoFile = await context.read<VideoFeedCubit>().getCachedVideoFile(video.videoUrl);
      }

      final controller = VideoPlayerController.file(
        videoFile,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
        ),
      );

      await controller.initialize().timeout(const Duration(seconds: 3), onTimeout: () {
        debugPrint('Controller initialization timed out');
        return;
      });

      controller.setLooping(false);
      controller.setPlaybackSpeed(video.playbackSpeed);
      _controllerCache[video.reelID] = controller;
      _touchController(video.reelID);

      controller.addListener(() {
        if (controller.value.isInitialized && controller.value.position == controller.value.duration) {
          _onVideoCompleted();
        }
      });

      _enforceCacheLimit();
      return controller;
    } catch (e) {
      debugPrint('Error initializing controller: $e');
      return null;
    }
  }

  void _onVideoCompleted() async {
    if (_videos.isEmpty || _currentPage >= _videos.length) return;
    final targetPage = (_currentPage + 1) % _videos.length;
    _currentlyPlayingVideoId = _videos[targetPage].reelID;
    await _pauseExceptCurrent(_currentlyPlayingVideoId!); // Ensure current video is paused before moving
    await _pageController.animateToPage(targetPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    if (mounted && targetPage < _videos.length && !context.read<VideoFeedCubit>().state.shouldPauseVideo) {
      // The _handlePageChange will be called by onPageChanged, which will handle playing the video.
      // No need to call _initAndPlayVideo here directly.
    }
  }

  Future<void> _pauseExceptCurrent(String currentVideoId) async {
    for (final entry in _controllerCache.entries) {
      if (entry.key != currentVideoId && entry.value.value.isInitialized) {
        await entry.value.pause();
        await entry.value.setVolume(0.0);
        await entry.value.seekTo(Duration.zero);
      }
    }
    // Double-check to ensure no audio leakage from other videos
    for (final entry in _controllerCache.entries) {
      if (entry.key != currentVideoId && entry.value.value.isInitialized && entry.value.value.isPlaying) {
        await entry.value.pause();
        await entry.value.setVolume(0.0);
      }
    }
  }

  Future<void> _removeController(String videoId) async {
    if (_disposingControllers.contains(videoId)) return;
    _disposingControllers.add(videoId);
    try {
      final controller = _controllerCache[videoId];
      if (controller != null) {
        _controllerCache.remove(videoId);
        _accessOrder.remove(videoId);
        if (controller.value.isInitialized) {
          await controller.pause();
        }
        await controller.dispose();
      }
    } finally {
      _disposingControllers.remove(videoId);
    }
  }

  void _enforceCacheLimit() {
    while (_controllerCache.length > _maxCacheSize && _accessOrder.isNotEmpty) {
      final oldestId = _accessOrder.first;
      _removeController(oldestId);
    }
  }

  Future<void> _disposeAllControllers() async {
    final controllerIds = List<String>.from(_controllerCache.keys);
    for (final id in controllerIds) {
      await _removeController(id);
    }
    _controllerCache.clear();
    _accessOrder.clear();
  }

  Future<void> _manageControllerWindow(int currentPage) async {
    if (_videos.isEmpty) return;
    final windowStart = (currentPage - 1).clamp(0, _videos.length - 1);
    final windowEnd = (currentPage + 2).clamp(0, _videos.length - 1);
    final idsToKeep = <String>{};
    for (int i = windowStart; i <= windowEnd; i++) {
      if (i < _videos.length) {
        idsToKeep.add(_videos[i].reelID);
      }
    }
    final idsToDispose = _controllerCache.keys.where((id) => !idsToKeep.contains(id)).toList();
    for (final id in idsToDispose) {
      if (_disposingControllers.contains(id)) continue;
      await _removeController(id);
    }
    if (currentPage < _videos.length) {
      await _getOrCreateController(_videos[currentPage], highPriority: true);
      if (currentPage + 1 < _videos.length) {
        _getOrCreateController(_videos[currentPage + 1], highPriority: true);
      }
      if (currentPage - 1 >= 0) {
        _getOrCreateController(_videos[currentPage - 1], highPriority: false);
      }
    }
    setState(() {});
  }

  Future<void> _handlePageChange(int newPage) async {
    if (_videos.isEmpty || newPage >= _videos.length || _isHandlingPageChange) return;
    _isHandlingPageChange = true;
    try {
      _currentPage = newPage;
      _currentlyPlayingVideoId = _videos[newPage].reelID;
      // Pause all except the target video
      await _pauseExceptCurrent(_currentlyPlayingVideoId!); // Ensure current video is paused before moving
      await _manageControllerWindow(newPage);
      if (!context.read<VideoFeedCubit>().state.shouldPauseVideo) {
        await _initAndPlayVideo(newPage);
      }
      _preloadTimer?.cancel();
      _preloadTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<VideoFeedCubit>().onPageChanged(newPage);
        }
      });
    } finally {
      _isHandlingPageChange = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      child: Container(
        color: Colors.black,
        child: BlocListener<VideoFeedCubit, VideoFeedState>(
          listenWhen: (p, c) =>
          p.videos != c.videos ||
              p.isLoading != c.isLoading ||
              p.preloadedVideoUrls != c.preloadedVideoUrls ||
              p.shouldPauseVideo != c.shouldPauseVideo ||
              p.loadingSource != c.loadingSource,
          listener: (context, state) async {
            if (state.loadingSource == 'background' && state.isLoading) {
              setState(() {
                _showingBackgroundRefresh = true;
              });
            }
            else if (_showingBackgroundRefresh && !state.isLoading) {
              setState(() {
                _showingBackgroundRefresh = false;
              });
            }
            if (state.videos != _videos) {
              setState(() => _videos = state.videos);
              _manageControllerWindow(_currentPage);
            }
            if (state.videos.isNotEmpty && !_initialVideosLoaded) {
              _initialVideosLoaded = true;
              if (!state.shouldPauseVideo) {
                _initAndPlayVideo(0);
              }
            }
            if (state.shouldPauseVideo && _currentlyPlayingVideoId != null) {
              await _pauseExceptCurrent(_currentlyPlayingVideoId!); // Ensure current video is paused before moving
            }
            else if (!state.shouldPauseVideo && _isAppActive) {
              await _initAndPlayVideo(_currentPage);
            }
          },
          child: Stack(
            children: [
              PreloadPageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,
                itemCount: _videos.length,
                preloadPagesCount: 2,
                onPageChanged: (index) => _handlePageChange(index),
                itemBuilder: (context, index) {
                  return RepaintBoundary(
                    child: VideoFeedItem(
                      key: ValueKey(_videos[index].reelID),
                      controller: _getController(_videos[index].reelID),
                      reel: _videos[index],
                      isComingFromHome: true,
                    ),
                  );
                },
              ),
              if (_showingBackgroundRefresh)
                Positioned(
                  top: 120,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Refreshing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              StreamBuilder(
                stream: UserService.getCurrentUserStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    String mood = snapshot.requireData.mood ?? 'Happy';
                    return Positioned(
                      top: 60,
                      left: 20,
                      right: 20,
                      child: GestureDetector(
                        onTap: () async {
                          final result = await showModalBottomSheet(
                            isDismissible: false,
                            context: context,
                            builder: (_) {
                              return MoodSelectingScrollWheelWidget(selectedMood: mood);
                            },
                          );
                          if (result != null) {
                            await _disposeAllControllers();
                            setState(() {
                              _currentPage = 0;
                              _videos = [];
                              _initialVideosLoaded = false;
                            });
                            if (_pageController.hasClients) {
                              _pageController.jumpToPage(0);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Loading $result reels...'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            context.read<VideoFeedCubit>().onMoodChange(mood: result);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppConstants.appTitle} V2',
                              style: AppTextStyles.headingTextStyle3.copyWith(color: Colors.white),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Row(
                                spacing: 20,
                                children: [
                                  Text(
                                    "${AppData.getEmojiByMood(mood)} $mood",
                                    style: AppTextStyles.bodyTextStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

