import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/app_router/app_router.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/services/reels_cache_service.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';

import '../../../app_data.dart';
import '../../../app_router/router_enum.dart';
import '../../../providers/report_content_provider.dart';
import 'bloc_cubit/updated_feed_cubit.dart';
import 'bloc_cubit/updated_feed_state.dart';
import '../../../res/app_constants.dart';
import '../../../res/app_textstyles.dart';
import '../../../services/user_service.dart';
import '../../../widgets/mood_selecting_scroll_wheel_widget.dart';
import 'widgets/updated_reels_player_widget.dart';
import '../widgets/video_feed_item.dart';
import '../../../loading_shimmers/reels_shimmer_widget.dart';

class UpdatedFeedView extends StatefulWidget {
  const UpdatedFeedView({super.key});

  @override
  State<UpdatedFeedView> createState() => _UpdatedFeedViewState();
}

class _UpdatedFeedViewState extends State<UpdatedFeedView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin, RouteAware {
  /// Maximum number of controllers to keep in cache
  final int _maxCacheSize = 8; // Reduced for better memory management

  /// The current videos to display
  List<ReelModel> _videos = [];

  /// Current visible page
  int _currentPage = 0;

  /// PageView controller
  final PreloadPageController _pageController = PreloadPageController();

  /// Whether the app is currently active
  bool _isAppActive = true;

  /// LRU cache of video controllers by video ID
  final Map<String, VideoPlayerController> _controllerCache = {};

  /// Ordered list of video IDs by most recently accessed
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

  /// Flag to track if we're currently handling a video completion
  bool _isHandlingCompletion = false;

  /// Flag to track if we're currently in the process of pausing all controllers
  bool _isPausingAllControllers = false;

  /// Flag to track if we're currently in the process of initializing a video
  bool _isInitializingVideo = false;

  /// Timer for delayed preloading to avoid overloading during fast scrolling
  Timer? _preloadTimer;

  @override
  bool get wantKeepAlive => true; // Keep state when widget is not visible

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize the UpdatedFeedCubit first
    Future.microtask(() {
      context.read<UpdatedFeedCubit>().initialize().then((_) {
        // Then initialize the first video after cubit is initialized
        _initializeFirstVideo();
      });
    });

    // Listen for refresh events from the UpdatedFeedCubit
    Future.microtask(() {
      final cubit = context.read<UpdatedFeedCubit>();
      cubit.stream.listen((state) {
        if (state.isLoading && !state.isPaginating && state.loadingSource == 'network') {
          _handleRefresh();
        }
      });
    });

    // Listen for report events from ReportContentProvider
    Future.microtask(() {
      final reportProvider = context.read<ReportContentProvider>();
      reportProvider.addListener(() {
        if (!reportProvider.isReporting) {
          String? reportedReelID;
          if (reportProvider.lastReportedReelID != null) {
            reportedReelID = reportProvider.lastReportedReelID;
            debugPrint("_lastReportedReelID received in the updatedFeedView: $reportedReelID");
            context.read<UpdatedFeedCubit>().removeReportedReel(reportedReelID!);
          }
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _disposeAllControllers();
    super.dispose();
  }

  @override
  void didPushNext() {
    _pauseAllControllers();
    context.read<UpdatedFeedCubit>().setShouldPauseVideo(true);
    super.didPushNext();
  }

  @override
  void didPopNext() {
    debugPrint("UpdatedFeedView: didPopNext called");
    super.didPopNext();
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final isMainFeedRoute = currentRoute == RouterEnum.videoFeedView.routeName;

    if (isMainFeedRoute) {
      context.read<UpdatedFeedCubit>().setShouldPauseVideo(false);
      _manageControllerWindow(_currentPage);
      if (mounted) {
        _initAndPlayVideo(_currentPage);
      }
      context.read<UpdatedFeedCubit>().preloadNextVideos();
    } else {
      context.read<UpdatedFeedCubit>().setShouldPauseVideo(true);
      _pauseAllControllers();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _isAppActive;
    _isAppActive = state == AppLifecycleState.resumed;

    if (_isAppActive && !wasActive) {
      _cleanupAndReinitializeCurrentVideo();
    } else if (!_isAppActive && wasActive) {
      _pauseAllControllers();
    }
  }

  void _initializeFirstVideo() async {
    final state = context.read<UpdatedFeedCubit>().state;
    if (state.videos.isNotEmpty) {
      debugPrint("Initialize First video: ${state.videos.length}");
      setState(() {
        _videos = state.videos;
        _initialVideosLoaded = true;
      });

      if (_videos.isNotEmpty) {
        await _getOrCreateController(_videos[0], highPriority: true);
      }

      for (int i = 1; i < math.min(3, _videos.length); i++) {
        _getOrCreateController(_videos[i], highPriority: i <= 1);
      }

      if (!context.read<UpdatedFeedCubit>().state.shouldPauseVideo) {
        await _initAndPlayVideo(0);
      }

      if (mounted) {
        setState(() {});
      }
    }
    debugPrint("Initializing videos empty First video: ${state.videos.length}");
  }

  void _handleRefresh() {
    _pauseAllControllers();
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
    await _pauseAllControllers();
    final videoId = _videos[_currentPage].reelID;
    final controller = _getController(videoId);

    if (controller != null && (controller.value.hasError || !controller.value.isInitialized)) {
      await _removeController(videoId);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await _manageControllerWindow(_currentPage);
    await _initAndPlayVideo(_currentPage);
  }

  Future<void> _initAndPlayVideo(int index) async {
    if (_videos.isEmpty || index >= _videos.length || _isInitializingVideo) return;
    _isInitializingVideo = true;

    try {
      bool shouldPause = context.read<UpdatedFeedCubit>().state.shouldPauseVideo;
      if (shouldPause && _currentlyPlayingVideoId == null) {
        _isInitializingVideo = false;
        return;
      }

      final videoToPlay = _videos[index];
      final videoId = videoToPlay.reelID;
      _currentlyPlayingVideoId = videoId;

      await _pauseAllControllers();

      if (_currentlyPlayingVideoId != videoId) {
        _isInitializingVideo = false;
        return;
      }

      context.read<UpdatedFeedCubit>().state.preloadedVideoUrls.contains(videoToPlay.videoUrl);

      VideoPlayerController? controller = await _getOrCreateController(videoToPlay, highPriority: true);

      if (_currentlyPlayingVideoId != videoId) {
        _isInitializingVideo = false;
        return;
      }

      for (final ctrl in _controllerCache.values) {
        if (ctrl.value.isInitialized && ctrl.dataSource != videoToPlay.videoUrl) {
          await ctrl.pause();
          await ctrl.setVolume(0.0);
          await ctrl.seekTo(Duration.zero);
        }
      }

      if (controller != null && controller.value.isInitialized) {
        await controller.seekTo(Duration.zero);
        if (!videoToPlay.isMuted) {
          await controller.setVolume(1.0);
          debugPrint("Setting volume to 1.0 for video ${videoToPlay.reelID}");
        } else {
          await controller.setVolume(0.0);
          debugPrint("Setting volume to 0.0 for muted video ${videoToPlay.reelID}");
        }

        if (_currentlyPlayingVideoId != videoId) {
          _isInitializingVideo = false;
          return;
        }

        if (_currentlyPlayingVideoId != videoId || !mounted) {
          _isInitializingVideo = false;
          return;
        }

        await controller.play();
        debugPrint("Playing video at index $index: ${videoToPlay.reelID}");

        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted && _currentlyPlayingVideoId == videoId && controller.value.isInitialized && !controller.value.isPlaying) {
            controller.play();
            debugPrint("Retrying playback for video at index $index: ${videoToPlay.reelID}");
          }
        });
      } else {
        if (_currentlyPlayingVideoId == videoId) {
          _playController(videoId);
        }
      }

      if (mounted && _currentlyPlayingVideoId == videoId) {
        setState(() {});
      }

      _preloadTimer?.cancel();
      _preloadTimer = Timer(const Duration(milliseconds: 50), () {
        if (mounted) {
          context.read<UpdatedFeedCubit>().preloadNextVideos();
          ReelsCacheService.getCurrentMood().then((currentMood) {
            ReelsCacheService.getCachedReels(currentMood);
          });
        }
      });
    } finally {
      _isInitializingVideo = false;
    }
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
      File? videoFile;
      bool isFromCache = false;

      videoFile = await ReelsCacheService.getCachedVideo(video.videoUrl);
      if (videoFile != null && await videoFile.exists()) {
        isFromCache = true;
      }

      if (videoFile == null) {
        try {
          videoFile = await context.read<UpdatedFeedCubit>().getCachedVideoFile(video.videoUrl);
          isFromCache = true;
        } catch (e) {
          debugPrint('Error getting cached file from cubit: $e');
          final tempDir = await getTemporaryDirectory();
          videoFile = File('${tempDir.path}/fallback_${DateTime.now().millisecondsSinceEpoch}.mp4');
          if (!await videoFile.exists()) {
            await videoFile.create();
          }
        }
      }

      final controller = VideoPlayerController.file(
        videoFile,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
      );

      try {
        await controller.initialize().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint('Controller initialization timed out, continuing anyway');
            return;
          },
        );
      } catch (e) {
        debugPrint('Error initializing controller, continuing anyway: $e');
      }

      controller.setLooping(false);
      controller.setPlaybackSpeed(video.playbackSpeed);
      _controllerCache[video.reelID] = controller;
      _touchController(video.reelID);

      controller.addListener(() {
        final position = controller.value.position;
        final duration = controller.value.duration;
        bool reachedAtEnd = position.inSeconds == duration.inSeconds;
        debugPrint("Video: ${video.caption}\nController duration: ${controller.value.duration.inSeconds} and position: ${controller.value.position.inSeconds}\nIsCompleted: $reachedAtEnd");

        if (controller.value.isInitialized && reachedAtEnd) {
          debugPrint("✅ Video completed: ${video.reelID}");
          _onVideoCompleted();
        }
      });

      _enforceCacheLimit();

      if (isFromCache && highPriority) {
        if (controller.value.isInitialized && !controller.value.isPlaying && _currentlyPlayingVideoId == video.reelID) {
          controller.play();
        }
      }

      return controller;
    } catch (e) {
      debugPrint('Error initializing controller: $e');
      return null;
    }
  }

  void _playController(String videoId) {
    final controller = _controllerCache[videoId];
    if (controller != null && controller.value.isInitialized && !controller.value.isPlaying) {
      try {
        controller.play();
      } catch (e) {
        debugPrint('Error playing video: $e');
      }
    }
  }

  void _onVideoCompleted() async {
    debugPrint("_onVideoCompleted called");
    if (_isHandlingCompletion) {
      return;
    }

    _isHandlingCompletion = true;

    try {
      final targetPage = (_currentPage + 1) % _videos.length;
      await _pauseAllControllers();

      if (!mounted) {
        debugPrint("Widget not mounted, aborting");
        _isHandlingCompletion = false;
        return;
      }

      debugPrint("Animating to page $targetPage");
      await _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      if (mounted && targetPage < _videos.length && !context.read<UpdatedFeedCubit>().state.shouldPauseVideo) {
        await _pauseAllControllers();
        _currentlyPlayingVideoId = _videos[targetPage].reelID;
        await _initAndPlayVideo(targetPage);
      }
    } catch (e) {
    } finally {
      _isHandlingCompletion = false;
    }
  }

  Future<void> _pauseAllControllers() async {
    if (_isPausingAllControllers) return;
    _isPausingAllControllers = true;

    try {
      final controllers = List<VideoPlayerController>.from(_controllerCache.values);
      for (final controller in controllers) {
        try {
          if (controller.value.isInitialized) {
            if (controller.value.isPlaying) {
              await controller.pause();
            }
            await controller.setVolume(0.0);
          }
        } catch (e) {
          debugPrint('Error in first pass pause: $e');
        }
      }

      for (final controller in controllers) {
        try {
          if (controller.value.isInitialized) {
            if (controller.value.isPlaying) {
              await controller.pause();
            }
            await controller.setVolume(0.0);
            await controller.seekTo(Duration.zero);
          }
        } catch (e) {
          debugPrint('Error in second pass cleanup: $e');
        }
      }
    } finally {
      _isPausingAllControllers = false;
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
          controller.pause();
        }
        try {
          await controller.dispose();
        } catch (e) {
          debugPrint('Error disposing controller: $e');
        }
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
    final windowStart = (currentPage - 2).clamp(0, _videos.length - 1);
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
      for (int i = 1; i <= 2; i++) {
        if (currentPage + i < _videos.length) {
          unawaited(_getOrCreateController(_videos[currentPage + i], highPriority: i <= 1));
        }
      }
      for (int i = 1; i <= 2; i++) {
        if (currentPage - i >= 0) {
          unawaited(_getOrCreateController(_videos[currentPage - i], highPriority: i <= 1));
        }
      }
    }
    setState(() {});
  }

  Future<void> _handlePageChange(int newPage) async {
    if (_videos.isEmpty) return;
    if (newPage >= _videos.length) {
      context.read<UpdatedFeedCubit>().preloadNextVideos();
      return;
    }

    if (_isHandlingPageChange) {
      _currentPage = newPage;
      return;
    }

    _isHandlingPageChange = true;

    try {
      final previousPage = _currentPage;
      _currentPage = newPage;
      final isFastScroll = (newPage - previousPage).abs() > 1;

      await _pauseAllControllers();

      if (newPage < _videos.length) {
        _currentlyPlayingVideoId = _videos[newPage].reelID;
      }

      final windowStart = (newPage - 2).clamp(0, _videos.length - 1);
      final windowEnd = (newPage + 2).clamp(0, _videos.length - 1);

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

      _manageControllerWindow(newPage);

      if (_videos.isNotEmpty && newPage < _videos.length && !context.read<UpdatedFeedCubit>().state.shouldPauseVideo) {
        await _pauseAllControllers();
        _currentlyPlayingVideoId = _videos[newPage].reelID;
        if (mounted) {
          _initAndPlayVideo(newPage).then((_) {
            debugPrint("Playing visible reel at index $newPage after manual page change");
          }).catchError((e) {
            debugPrint("Error initializing/playing video at index $newPage: $e");
          });
        }
      }

      _preloadTimer?.cancel();
      _preloadTimer = Timer(const Duration(milliseconds: 50), () {
        if (mounted) {
          debugPrint("Notifying cubit of page change to index $newPage, total videos: ${_videos.length}");
          context.read<UpdatedFeedCubit>().onPageChanged(newPage);
        }
      });
    } catch (e) {
      debugPrint('Error handling page change: $e');
    } finally {
      _isHandlingPageChange = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("UpdatedFeedView");
    super.build(context);
    return RepaintBoundary(
      child: Container(
        color: Colors.black,
        child: BlocListener<UpdatedFeedCubit, UpdatedFeedState>(
          listenWhen: (p, c) =>
              p.videos != c.videos ||
              p.isLoading != c.isLoading ||
              p.preloadedVideoUrls != c.preloadedVideoUrls ||
              p.shouldPauseVideo != c.shouldPauseVideo ||
              p.loadingSource != c.loadingSource,
          listener: (context, state) {
            if (state.loadingSource == 'background' && state.isLoading) {
              setState(() {
                _showingBackgroundRefresh = true;
              });
            } else if (_showingBackgroundRefresh && !state.isLoading) {
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

            if (state.shouldPauseVideo && _currentlyPlayingVideoId == null) {
              debugPrint("shouldPauseVideo received in build: ${state.shouldPauseVideo}");
              _pauseAllControllers();
            } else if (!state.shouldPauseVideo && _isAppActive) {
              final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
              final isMainFeedRoute = currentRoute == RouterEnum.videoFeedView.routeName;

              if (isMainFeedRoute && _currentlyPlayingVideoId == null) {
                _initAndPlayVideo(_currentPage);
              }
            }
          },
          child: Stack(
            children: [
              PreloadPageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,
                physics: ScrollPhysics(),
                itemCount: _videos.length + 1,
                preloadPagesCount: 2,
                onPageChanged: (index) => _handlePageChange(index),
                itemBuilder: (context, index) {
                  if (index < _videos.length) {
                    return RepaintBoundary(
                      child: VideoFeedItem(
                        key: ValueKey(_videos[index].reelID),
                        controller: _getController(_videos[index].reelID),
                        reel: _videos[index],
                        isComingFromHome: true,
                      ),
                    );
                  } else {
                    return RepaintBoundary(
                      child: ReelsShimmerWidget(),
                    );
                  }
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
                            if (result == mood) {
                              return;
                            }
                            await _pauseAllControllers();
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
                            context.read<UpdatedFeedCubit>().onMoodChange(mood: result);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppConstants.appTitle} V3.3',
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
