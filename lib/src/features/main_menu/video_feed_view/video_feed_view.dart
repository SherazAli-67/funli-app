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
import 'bloc_cubit/video_feed_cubit.dart';
import 'bloc_cubit/video_feed_state.dart';
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
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin, RouteAware {
  /// Maximum number of controllers to keep in cache
  final int _maxCacheSize = 8; // Increased for smoother fast scrolling

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
    // Initialize the VideoFeedCubit first
    Future.microtask(() {
      // Initialize the cubit to load videos from cache or network
      context.read<VideoFeedCubit>().initialize().then((_) {
        // Then initialize the first video after cubit is initialized
        _initializeFirstVideo();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _disposeAllControllers();
    super.dispose();
  }

  // Called when this route is no longer visible
  @override
  void didPushNext() {
    debugPrint("VideoFeedView: didPushNext called");
    // Pause all videos when navigating away
    _pauseAllControllers();

    // Set shouldPauseVideo to true when navigating away
    // This ensures videos remain paused when returning
    context.read<VideoFeedCubit>().setShouldPauseVideo(true);

    super.didPushNext();
  }

  // Called when this route becomes visible again
  @override
  void didPopNext() {
    debugPrint("VideoFeedView: didPopNext called");
    super.didPopNext();

    // Check if we're returning from create_upload_feel page
    // If so, we need to check the current route to determine if we should resume playing
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final isMainFeedRoute = currentRoute == RouterEnum.videoFeedView.routeName;

    // Only resume playing if we're on the main feed route
    if (isMainFeedRoute) {
      // Reset shouldPauseVideo to false since we're back on the main feed
      context.read<VideoFeedCubit>().setShouldPauseVideo(false);

      // First reinitialize the controller window to ensure proper caching
      _manageControllerWindow(_currentPage);

      // Then play the current video with a slight delay to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _initAndPlayVideo(_currentPage);
        }
      });

      // Request the cubit to preload videos for smoother experience
      context.read<VideoFeedCubit>().preloadNextVideos();
    } else {
      // If we're on a different tab, keep videos paused
      context.read<VideoFeedCubit>().setShouldPauseVideo(true);
      _pauseAllControllers();
    }
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

  void _initializeFirstVideo() async {
    final state = context.read<VideoFeedCubit>().state;
    if (state.videos.isNotEmpty) {
      debugPrint("Initialize First video: ${state.videos.length}");
      setState(() {
        _videos = state.videos;
        _initialVideosLoaded = true;
      });

      // Pre-initialize controllers for first few videos with priority
      // First video gets highest priority
      if (_videos.isNotEmpty) {
        await _getOrCreateController(_videos[0], highPriority: true);
      }

      // Preload next videos for even smoother experience
      for (int i = 1; i < math.min(5, _videos.length); i++) {
        _getOrCreateController(_videos[i], highPriority: i <= 2);
      }

      // Only play the first video if we're not supposed to pause
      if (!context.read<VideoFeedCubit>().state.shouldPauseVideo) {
        // Play the first video after a short delay to ensure controller is ready
        await Future.delayed(const Duration(milliseconds: 50));
        await _initAndPlayVideo(0);
      }

      if (mounted) {
        setState(() {});
      }
    }
    debugPrint("Initializing videos empty First video: ${state.videos.length}");
  }

  /// Clean up and reinitialize the current video when coming back from background
  Future<void> _cleanupAndReinitializeCurrentVideo() async {
    if (_videos.isEmpty || _currentPage >= _videos.length) return;

    // First pause all controllers to ensure clean state
    await _pauseAllControllers();

    final videoId = _videos[_currentPage].reelID;
    final controller = _getController(videoId);

    // If controller exists but has errors or isn't initialized, recreate it
    if (controller != null &&
        (controller.value.hasError || !controller.value.isInitialized)) {
      await _removeController(videoId);
      // Short delay to ensure controller is fully disposed
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Manage the controller window to ensure proper caching
    await _manageControllerWindow(_currentPage);

    // Reinitialize and play current video with high priority
    await _initAndPlayVideo(_currentPage);
  }

  /// Initialize and play a video at the given index
  Future<void> _initAndPlayVideo(int index) async {
    if (_videos.isEmpty || index >= _videos.length || _isInitializingVideo) return;

    _isInitializingVideo = true;

    try {
      // Check if we should pause videos (e.g., when on a different tab)
      if (context.read<VideoFeedCubit>().state.shouldPauseVideo) {
        _isInitializingVideo = false;
        return;
      }

      // Store the video ID we're trying to play
      final videoToPlay = _videos[index];
      final videoId = videoToPlay.reelID;
      _currentlyPlayingVideoId = videoId;

      // First ensure all other videos are completely paused and muted
      // This is critical to prevent audio leakage
      await _pauseAllControllers();

      // If another video was requested to play while we were pausing, abort
      if (_currentlyPlayingVideoId != videoId) {
        _isInitializingVideo = false;
        return;
      }

      // Check if this video is already preloaded in the cubit
      final isPreloaded = context.read<VideoFeedCubit>().state.preloadedVideoUrls.contains(videoToPlay.videoUrl);

      // Get or create the controller with high priority for current video
      VideoPlayerController? controller = await _getOrCreateController(videoToPlay, highPriority: true);

      // If another video was requested to play while we were getting the controller, abort
      if (_currentlyPlayingVideoId != videoId) {
        _isInitializingVideo = false;
        return;
      }

      // Double-check all controllers are truly paused and muted
      // This prevents the issue where audio from next video plays
      for (final controller in _controllerCache.values) {
        if (controller.value.isInitialized &&
            controller.dataSource != videoToPlay.videoUrl) {
          controller.pause();
          controller.setVolume(0.0);
          // Reset position to beginning for a clean state
          controller.seekTo(Duration.zero);
        }
      }

      // Ensure volume is restored to full when playing video
      if (controller != null && controller.value.isInitialized) {
        // Reset position to beginning to ensure smooth start
        await controller.seekTo(Duration.zero);

        // Set volume before playing - ALWAYS set to 1.0 unless explicitly muted
        if(!videoToPlay.isMuted){
          await controller.setVolume(1.0);
          debugPrint("Setting volume to 1.0 for video ${videoToPlay.reelID}");
        } else {
          await controller.setVolume(0.0);
          debugPrint("Setting volume to 0.0 for muted video ${videoToPlay.reelID}");
        }

        // Check again if we should still play this video
        if (_currentlyPlayingVideoId != videoId) {
          _isInitializingVideo = false;
          return;
        }

        // For preloaded videos, play immediately
        if (isPreloaded) {
          controller.play();
        } else {
          // For non-preloaded videos, use the normal play method
          _playController(videoId);
        }
      } else {
        // If controller isn't initialized yet, use the normal play method
        if (_currentlyPlayingVideoId == videoId) {
          _playController(videoId);
        }
      }

      if (mounted && _currentlyPlayingVideoId == videoId) {
        setState(() {});
      }

      // Trigger preloading of next videos with a slight delay to avoid overloading
      _preloadTimer?.cancel();
      _preloadTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<VideoFeedCubit>().preloadNextVideos();

          // Preload videos for the current mood to ensure smooth playback
          ReelsCacheService.getCurrentMood().then((currentMood) {
            ReelsCacheService.getCachedReels(currentMood);
          });
        }
      });
    } finally {
      _isInitializingVideo = false;
    }
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
  Future<VideoPlayerController?> _getOrCreateController(ReelModel video, {bool highPriority = false}) async {
    // Return the existing controller if available
    if (_controllerCache.containsKey(video.reelID)) {
      _touchController(video.reelID);
      return _controllerCache[video.reelID];
    }

    try {
      File? videoFile;
      bool isFromCache = false;

      // Check if this video is already preloaded in the cubit
      final isPreloaded = context.read<VideoFeedCubit>().state.preloadedVideoUrls.contains(video.videoUrl);

      // First try to get from ReelsCacheService directly for faster loading
      videoFile = await ReelsCacheService.getCachedVideo(video.videoUrl);
      if (videoFile != null && await videoFile.exists()) {
        isFromCache = true;
      }

      // If not found in direct cache, get from cubit which will handle downloading
      if (videoFile == null) {
        try {
          videoFile = await context.read<VideoFeedCubit>().getCachedVideoFile(
            video.videoUrl,
          );
          // If cubit returned a file, it's from cache
          isFromCache = true;
        } catch (e) {
          debugPrint('Error getting cached file from cubit: $e');
          // Create a fallback file to prevent crashes
          final tempDir = await getTemporaryDirectory();
          videoFile = File('${tempDir.path}/fallback_${DateTime.now().millisecondsSinceEpoch}.mp4');
          if (!await videoFile.exists()) {
            await videoFile.create();
          }
        }
      }

      // Create a new controller with optimized settings for cached videos
      final controller = VideoPlayerController.file(
        videoFile,
        // Use lower buffer size for cached files to reduce memory usage and startup time
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false, // Ensure audio doesn't mix with other apps
        ),
      );

      // Start with volume at 0 to prevent audio leakage during initialization
      await controller.setVolume(0.0);
      
      // Add completion listener to automatically advance to next video
      controller.addListener(() {
        if (controller.value.isInitialized && 
            controller.value.position >= controller.value.duration - const Duration(milliseconds: 500) &&
            !controller.value.isBuffering &&
            controller.value.isPlaying) {
          _onVideoCompleted();
        }
      });

      try {
        // Initialize the controller with timeout
        await controller.initialize().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('Controller initialization timed out, continuing anyway');
            return;
          },
        );
      } catch (e) {
        debugPrint('Error initializing controller, continuing anyway: $e');
      }

      // Set looping to true for smoother playback experience
      // We'll handle manual progression to next video on completion
      controller.setLooping(true);

      // Set playback speed
      controller.setPlaybackSpeed(video.playbackSpeed);

      // Add to cache and update access order
      _controllerCache[video.reelID] = controller;
      _touchController(video.reelID);

      // Enforce cache size limit
      _enforceCacheLimit();

      // For cached videos with high priority, start playing immediately to avoid buffering perception
      if (isFromCache && isPreloaded && highPriority) {
        // Use a very short delay to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 50), () {
          if (controller.value.isInitialized &&
              !controller.value.isPlaying &&
              _currentlyPlayingVideoId == video.reelID) {
            controller.play();
          }
        });
      }

      return controller;
    } catch (e) {
      debugPrint('Error initializing controller: $e');
      return null;
    }
  }

  /// Play a controller if it exists and is initialized
  void _playController(String videoId) {
    final controller = _controllerCache[videoId];
    if (controller != null &&
        controller.value.isInitialized &&
        !controller.value.isPlaying) {
      try {
        controller.play();
      } catch (e) {
        debugPrint('Error playing video: $e');
      }
    }
  }

  void _onVideoCompleted() {
    // Prevent multiple calls from causing double navigation
    if (_isHandlingCompletion) return;

    if (_currentPage + 1 < _videos.length) {
      _isHandlingCompletion = true;

      // Store the target page to ensure we navigate to the correct one
      final targetPage = _currentPage + 1;

      // First pause all videos to prevent audio leakage
      _pauseAllControllers().then((_) {
        // Only proceed if we're still handling the same completion event
        if (!_isHandlingCompletion) return;

        // Navigate to the next page
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ).then((_) {
          // After animation completes, ensure we're on the correct page
          // and play the video at that page
          if (mounted && _currentPage == targetPage) {
            _initAndPlayVideo(targetPage);
          }

          // Reset the flag after navigation completes
          _isHandlingCompletion = false;
        });
      });
    } else {
      _isHandlingCompletion = false;
    }
  }

  /// Pause all controllers - optimized for fast page changes
  Future<void> _pauseAllControllers() async {
    // Prevent concurrent calls to _pauseAllControllers
    if (_isPausingAllControllers) return;

    _isPausingAllControllers = true;

    try {
      // Create a copy of the controllers to avoid concurrent modification
      final controllers = List<VideoPlayerController>.from(
        _controllerCache.values,
      );

      // First pass: immediately pause all controllers without waiting
      // This ensures videos stop playing as quickly as possible
      for (final controller in controllers) {
        try {
          if (controller.value.isInitialized && controller.value.isPlaying) {
            controller.pause();
          }
        } catch (e) {
          // Ignore errors in first pass
        }
      }

      // Immediately mute all controllers to prevent audio leakage
      for (final controller in controllers) {
        try {
          if (controller.value.isInitialized) {
            controller.setVolume(0.0);
          }
        } catch (e) {
          // Ignore errors in first pass
        }
      }

      // Second pass: complete the cleanup operations
      for (final controller in controllers) {
        try {
          if (controller.value.isInitialized) {
            // Ensure volume is set to 0 again (double-check)
            await controller.setVolume(0.0);
            // Reset position to beginning
            await controller.seekTo(Duration.zero);
          }
        } catch (e) {
          debugPrint('Error pausing video: $e');
        }
      }

      // Update the currently playing video ID to null to prevent race conditions
      _currentlyPlayingVideoId = null;
    } finally {
      _isPausingAllControllers = false;
    }
  }

  /// Remove a controller from cache and dispose it
  Future<void> _removeController(String videoId) async {
    if (_disposingControllers.contains(videoId)) return;

    _disposingControllers.add(videoId);

    try {
      final controller = _controllerCache[videoId];
      if (controller != null) {
        // Remove from cache immediately to prevent further access
        _controllerCache.remove(videoId);
        _accessOrder.remove(videoId);

        // Pause immediately without waiting to ensure video stops playing
        if (controller.value.isInitialized) {
          controller.pause();
        }

        // Then dispose properly
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
    // Don't dispose the page controller here as it's needed for the lifetime of the widget
    // Only dispose video controllers

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

    // Define a window that includes 3 previous and 3 next videos
    final windowStart = (currentPage - 3).clamp(0, _videos.length - 1);
    final windowEnd = (currentPage + 3).clamp(0, _videos.length - 1);

    // Get IDs in window
    final idsToKeep = <String>{};
    for (int i = windowStart; i <= windowEnd; i++) {
      if (i < _videos.length) {
        idsToKeep.add(_videos[i].reelID);
      }
    }

    // Dispose controllers outside window without waiting
    final idsToDispose =
    _controllerCache.keys.where((id) => !idsToKeep.contains(id)).toList();
    for (final id in idsToDispose) {
      _removeController(id);
    }

    // Initialize controllers in window with priority order
    if (currentPage < _videos.length) {
      // Current page first - await this one to ensure it's ready
      await _getOrCreateController(_videos[currentPage], highPriority: true);

      // Next pages - higher priority for the next two
      for (int i = 1; i <= 3; i++) {
        if (currentPage + i < _videos.length) {
          unawaited(_getOrCreateController(_videos[currentPage + i], highPriority: i <= 2));
        }
      }
      // Previous pages - preload but lower priority
      for (int i = 1; i <= 3; i++) {
        if (currentPage - i >= 0) {
          unawaited(_getOrCreateController(_videos[currentPage - i], highPriority: false));
        }
      }
    }
  }

  /// Handle page changes in the video feed
  Future<void> _handlePageChange(int newPage) async {
    if (_videos.isEmpty || newPage >= _videos.length) return;

    // Prevent concurrent page change handling which can cause widget tree issues
    if (_isHandlingPageChange) {
      // Just update the current page and return - we'll handle it in the next cycle
      _currentPage = newPage;
      return;
    }

    _isHandlingPageChange = true;

    try {
      final previousPage = _currentPage;
      _currentPage = newPage;

      // For fast scrolling, be more aggressive
      final isFastScroll = (newPage - previousPage).abs() > 1;

      // First pause all videos immediately - this is critical to stop previous videos
      await _pauseAllControllers();

      // For fast scrolling, immediately dispose controllers to prevent memory issues
      if (isFastScroll) {
        // Keep only the target video controller
        final videoId = _videos[newPage].reelID;
        final idsToDispose = List<String>.from(_controllerCache.keys);

        for (final id in idsToDispose) {
          if (id != videoId) {
            // Don't await to keep UI responsive
            _removeController(id);
          }
        }
      } else {
        // For normal scrolling, immediately dispose controllers outside the window
        // This is more efficient than disposing just the previous controller
        final windowStart = (newPage - 2).clamp(0, _videos.length - 1);
        final windowEnd = (newPage + 2).clamp(0, _videos.length - 1);

        // Get IDs in window
        final idsToKeep = <String>{};
        for (int i = windowStart; i <= windowEnd; i++) {
          if (i < _videos.length) {
            idsToKeep.add(_videos[i].reelID);
          }
        }

        // Dispose controllers outside window
        final idsToDispose = _controllerCache.keys.where((id) => !idsToKeep.contains(id)).toList();
        for (final id in idsToDispose) {
          // Don't await to keep UI responsive
          _removeController(id);
        }
      }

      // Manage the window controllers - don't await to keep UI responsive
      _manageControllerWindow(newPage);

      // Play only the current video if we're not supposed to pause
      if (_videos.isNotEmpty && newPage < _videos.length && !context.read<VideoFeedCubit>().state.shouldPauseVideo) {
        // Use a slight delay to ensure previous video is fully paused
        await Future.delayed(const Duration(milliseconds: 50));
        await _initAndPlayVideo(newPage);
      }

      // Notify the cubit with a slight delay to avoid overloading
      _preloadTimer?.cancel();
      _preloadTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<VideoFeedCubit>().onPageChanged(newPage);
        }
      });
    } catch (e) {
      debugPrint('Error handling page change: $e');
    } finally {
      _isHandlingPageChange = false;
    }
    setState(() {});
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

              // Only play if we're not supposed to pause
              if (!state.shouldPauseVideo) {
                _initAndPlayVideo(0);
              }
            }

            // Handle video pausing
            if (state.shouldPauseVideo) {
              debugPrint("shouldPauseVideo received in build: ${state.shouldPauseVideo}");
              _pauseAllControllers();
            } else if (!state.shouldPauseVideo && _isAppActive) {
              // Check if we're on the video feed tab before playing
              final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();;
              final isMainFeedRoute = currentRoute == RouterEnum.videoFeedView.routeName;

              if (isMainFeedRoute) {
                _initAndPlayVideo(_currentPage);
              }
            }
          },
          child: Stack(
            children: [
              // Main video feed
              PreloadPageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,
                itemCount: _videos.length,
                preloadPagesCount: 3,
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

                                                // First pause all videos to prevent audio leakage
                                                await _pauseAllControllers();

                                                // Dispose all controllers to prevent memory leaks and audio issues
                                                await _disposeAllControllers();

                                                // Reset current page to ensure we start from the first video
                                                setState(() {
                                                  _currentPage = 0;
                                                  _videos = [];
                                                  _initialVideosLoaded = false;
                                                });

                                                // Reset page controller to index 0
                                                if (_pageController.hasClients) {
                                                  _pageController.jumpToPage(0);
                                                }

                                                // Show loading indicator while changing mood
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Loading ${result} reels...'),
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                );

                                                // Fetch new reels based on the mood
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
