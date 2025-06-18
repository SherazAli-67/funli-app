import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/services/reels_cache_service.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';

import '../../../app_data.dart';
import '../../../bloc_cubit/video_feed_cubit.dart';
import '../../../bloc_cubit/video_feed_state.dart';
import '../../../res/app_constants.dart';
import '../../../res/app_textstyles.dart';
import '../../../services/user_service.dart';
import '../../../widgets/mood_selecting_scroll_wheel_widget.dart';
import '../widgets/video_feed_item.dart';

class VideoFeedView extends StatefulWidget {
  const VideoFeedView({super.key});

  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  /// Maximum number of controllers to keep in cache
  final int _maxCacheSize = 5; // Increased for better performance

  /// The current videos to display
  List<ReelModel> _videos = [];

  /// Current visible page
  int _currentPage = 0;

  /// PageView controller
  final PreloadPageController _pageController = PreloadPageController(
    // preloadPagesCount: 3, // Preload 3 pages in each direction
  );

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
  
  @override
  bool get wantKeepAlive => true; // Keep state when widget is not visible

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFirstVideo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAllControllers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _isAppActive;
    _isAppActive = state == AppLifecycleState.resumed;

    if (_isAppActive && !wasActive) {
      // App has come back to foreground
      _cleanupAndReinitializeCurrentVideo();
    } else if (!_isAppActive && wasActive) {
      // App is going to background - pause all videos
      _pauseAllControllers();
    }
  }

  void _initializeFirstVideo() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = context.read<VideoFeedCubit>().state;
      if (state.videos.isNotEmpty) {
        _videos = state.videos;
        _initialVideosLoaded = true;
        
        // Pre-initialize controllers for first few videos
        for (int i = 0; i < math.min(3, _videos.length); i++) {
          await _getOrCreateController(_videos[i]);
        }
        
        // Play the first video
        await _initAndPlayVideo(0);
        
        if(mounted) {
          setState(() {});
        }
      }
    });
  }

  /// Clean up and reinitialize the current video when coming back from background
  Future<void> _cleanupAndReinitializeCurrentVideo() async {
    if (_videos.isEmpty || _currentPage >= _videos.length) return;

    await _pauseAllControllers();

    final videoId = _videos[_currentPage].reelID;
    final controller = _getController(videoId);

    // If controller exists but has errors, dispose it
    if (controller != null &&
        (controller.value.hasError || !controller.value.isInitialized)) {
      await _removeController(videoId);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Reinitialize and play current video
    await _initAndPlayVideo(_currentPage);
  }

  /// Initialize and play a video at the given index
  Future<void> _initAndPlayVideo(int index) async {
    if (_videos.isEmpty || index >= _videos.length) return;

    // First ensure all other videos are paused
    await _pauseAllControllers();
    
    final video = _videos[index];
    VideoPlayerController? controller = await _getOrCreateController(video);
    
    // Ensure volume is restored to full when playing video
    if (controller != null && controller.value.isInitialized) {
      // Reset position to beginning to ensure smooth start
      await controller.seekTo(Duration.zero);
      
      // Set volume before playing
      if(!video.isMuted){
        await controller.setVolume(1.0);
      } else {
        await controller.setVolume(0.0);
      }
    }
    
    // Play the video
    await _playController(video.reelID);

    if (mounted) setState(() {});
  }

  /// Get a controller for a video ID if it exists in the cache
  VideoPlayerController? _getController(String videoId) {
    return _controllerCache[videoId];
  }

  /// Touch a controller to mark it as recently used
  void _touchController(String videoId) {
    _accessOrder.remove(videoId);
    _accessOrder.add(videoId);
  }

  /// Get or create a controller for a video
  Future<VideoPlayerController?> _getOrCreateController(ReelModel video) async {
    // Return the existing controller if available
    if (_controllerCache.containsKey(video.reelID)) {
      _touchController(video.reelID);
      return _controllerCache[video.reelID];
    }

    try {
      File? videoFile;
      
      // First try to get from ReelsCacheService directly for faster loading
      videoFile = await ReelsCacheService.getCachedVideo(video.videoUrl);
      
      // If not found in direct cache, get from cubit which will handle downloading
      if (videoFile == null) {
        videoFile = await context.read<VideoFeedCubit>().getCachedVideoFile(
          video.videoUrl,
        );
      }

      // Create a new controller
      final controller = VideoPlayerController.file(videoFile);

      // Initialize the controller
      await controller.initialize();

      // Ensure volume is set correctly
      if(!video.isMuted){
        await controller.setVolume(1.0);
      } else {
        await controller.setVolume(0.0);
      }
      
      // Set looping to true to prevent buffering at the end of videos
      controller.setLooping(true);
      
      // Still detect when video completes a loop for auto-scrolling
      // controller.addListener(() {
      //   if (!mounted) return;
      //
      //   // Check if video has completed a loop (position near zero after playing)
      //   final isLoopCompleted = controller.value.position.inMilliseconds < 300 &&
      //                          controller.value.isPlaying &&
      //                          controller.value.duration.inSeconds > 1;
      //
      //   if (isLoopCompleted) {
      //     _onVideoCompleted();
      //   }
      // });

      controller.setPlaybackSpeed(video.playbackSpeed);

      // Add to cache and update access order
      _controllerCache[video.reelID] = controller;
      _touchController(video.reelID);

      // Enforce cache size limit
      _enforceCacheLimit();

      return controller;
    } catch (e) {
      debugPrint('Error initializing controller: $e');
      return null;
    }
  }

  /// Play a controller if it exists and is initialized
  Future<void> _playController(String videoId) async {
    final controller = _controllerCache[videoId];
    if (controller != null &&
        controller.value.isInitialized &&
        !controller.value.isPlaying) {
      try {
        await controller.play();
      } catch (e) {
        debugPrint('Error playing video: $e');
      }
    }
  }

  void _onVideoCompleted() {
    if (_currentPage + 1 < _videos.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Pause all controllers
  Future<void> _pauseAllControllers() async {
    // Create a copy of the controllers to avoid concurrent modification
    final controllers = List<VideoPlayerController>.from(
      _controllerCache.values,
    );

    for (final controller in controllers) {
      try {
        if (controller.value.isInitialized) {
          // Always pause, even if not playing, to ensure complete stop
          await controller.pause();
          // Mute to prevent audio leakage
          await controller.setVolume(0.0);
          // Reset position to beginning
          await controller.seekTo(Duration.zero);
        }
      } catch (e) {
        debugPrint('Error pausing video: $e');
      }
    }
  }

  /// Remove a controller from cache and dispose it
  Future<void> _removeController(String videoId) async {
    if (_disposingControllers.contains(videoId)) return;

    _disposingControllers.add(videoId);

    try {
      final controller = _controllerCache[videoId];
      if (controller != null) {
        // Remove from cache immediately
        _controllerCache.remove(videoId);
        _accessOrder.remove(videoId);

        // Pause and dispose
        try {
          if (controller.value.isInitialized) {
            await controller.pause();
          }
          await controller.dispose();
        } catch (e) {
          debugPrint('Error disposing controller: $e');
        }
      }
    } finally {
      _disposingControllers.remove(videoId);
    }
  }

  /// Enforce the cache size limit by removing least recently used controllers
  void _enforceCacheLimit() {
    // Only keep max number of controllers
    while (_controllerCache.length > _maxCacheSize && _accessOrder.isNotEmpty) {
      final oldestId = _accessOrder.first;
      _removeController(oldestId);
    }
  }

  /// Dispose all controllers
  Future<void> _disposeAllControllers() async {
    _pageController.dispose();

    final controllerIds = List<String>.from(_controllerCache.keys);
    for (final id in controllerIds) {
      await _removeController(id);
    }
    _controllerCache.clear();
    _accessOrder.clear();
  }

  /// Manage the window of controllers around the current page
  Future<void> _manageControllerWindow(int currentPage) async {
    if (_videos.isEmpty) return;

    // Define a smaller window to reduce memory usage and prevent background playback
    // Only preload next video, not previous (to prevent previous videos from playing)
    final windowStart = currentPage;
    final windowEnd = (currentPage + 1).clamp(0, _videos.length - 1);

    // Get IDs in window
    final idsToKeep = <String>{};
    for (int i = windowStart; i <= windowEnd; i++) {
      if (i < _videos.length) {
        idsToKeep.add(_videos[i].reelID);
      }
    }

    // Dispose controllers outside window
    final idsToDispose =
    _controllerCache.keys.where((id) => !idsToKeep.contains(id)).toList();
    for (final id in idsToDispose) {
      await _removeController(id);
    }

    // Initialize controllers in window with priority order
    if (currentPage < _videos.length) {
      // Current page first
      await _getOrCreateController(_videos[currentPage]);
      
      // Next page only
      if (currentPage + 1 < _videos.length) {
        await _getOrCreateController(_videos[currentPage + 1]);
      }
    }
  }

  /// Handle page changes in the video feed
  Future<void> _handlePageChange(int newPage) async {
    if (_videos.isEmpty || newPage >= _videos.length) return;

    final previousPage = _currentPage;
    _currentPage = newPage;

    // For fast scrolling, be more aggressive
    final isFastScroll = (newPage - previousPage).abs() > 1;

    // First pause all videos - this is critical to stop previous videos
    await _pauseAllControllers();

    try {
      if (isFastScroll) {
        // In fast scroll, dispose all except target
        final videoId = _videos[newPage].reelID;
        final idsToDispose = List<String>.from(_controllerCache.keys);

        for (final id in idsToDispose) {
          if (id != videoId) {
            await _removeController(id);
          }
        }
      } else {
        // For normal scrolling, immediately dispose the previous controller
        // to ensure it doesn't continue playing
        if (previousPage >= 0 && previousPage < _videos.length && previousPage != newPage) {
          final previousVideoId = _videos[previousPage].reelID;
          if (_controllerCache.containsKey(previousVideoId)) {
            // Don't await this to avoid blocking UI
            _removeController(previousVideoId);
          }
        }
      }

      // Manage the window controllers
      await _manageControllerWindow(newPage);

      // Play only the current video
      if (_videos.isNotEmpty && newPage < _videos.length) {
        await _initAndPlayVideo(newPage);
      }

      // Notify the cubit
      context.read<VideoFeedCubit>().onPageChanged(newPage);
    } catch (e) {
      debugPrint('Error handling page change: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
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
          listener: (context, state) {
            // Show background refresh indicator if loading from background
            if (state.loadingSource == 'background' && state.isLoading) {
              setState(() {
                _showingBackgroundRefresh = true;
              });
            } else if (_showingBackgroundRefresh && !state.isLoading) {
              setState(() {
                _showingBackgroundRefresh = false;
              });
            }
            
            // Update videos list
            if (state.videos != _videos) {
              setState(() => _videos = state.videos);
              _manageControllerWindow(_currentPage);
            }
            
            // Handle initial video loading
            if (state.videos.isNotEmpty && !_initialVideosLoaded) {
              _initialVideosLoaded = true;
              _initAndPlayVideo(0);
            }
            
            // Handle video pausing
            if (state.shouldPauseVideo) {
              debugPrint("shouldPauseVideo received in build: ${state.shouldPauseVideo}");
              _pauseAllControllers();
            } else if (!state.shouldPauseVideo && _isAppActive) {
              _initAndPlayVideo(_currentPage);
            }
          },
          child: Stack(
            children: [
              // Main video feed
              PreloadPageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,
                itemCount: _videos.length,
                preloadPagesCount: 2,
                physics: const AlwaysScrollableScrollPhysics(),
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
              
              // Background refresh indicator
              if (_showingBackgroundRefresh)
                Positioned(
                  top: 120,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
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
                  builder: (context, snapshot,) {
                    if(snapshot.hasData){
                      String mood = snapshot.requireData.mood ?? 'Happy';
                      return Positioned(
                          top: 60,
                          left: 20,
                          right: 20,
                          child: GestureDetector(
                            onTap: ()async{
                              final result = await showModalBottomSheet(
                                  isDismissible: false,
                                  context: context, builder: (_){
                                return MoodSelectingScrollWheelWidget(selectedMood: mood,);
                              });

                              if(result != null){
                                debugPrint("result found: $result");
                                // Clear existing feed
                                //Fetch new reels based on the mood
                                context.read<VideoFeedCubit>().onMoodChange(mood: result);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${AppConstants.appTitle} V2', style: AppTextStyles.headingTextStyle3.copyWith(color: Colors.white),),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(99)
                                  ),
                                  child: Row(
                                    spacing: 20,
                                    children: [
                                      Text("${AppData.getEmojiByMood(mood)} $mood", style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w600),),
                                      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white,)
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ));
                    }

                    return SizedBox();
                  }
              )
            ],
          ),
        ),
      ),
    );
  }
}
