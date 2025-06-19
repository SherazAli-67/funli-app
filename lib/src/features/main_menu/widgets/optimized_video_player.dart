import 'dart:async';

import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/play_pause_widget.dart';
import 'package:video_player/video_player.dart';

class OptimizedVideoPlayer extends StatefulWidget {
  const OptimizedVideoPlayer({
    super.key,
    required this.controller,
    required this.reelID,
  });

  final VideoPlayerController? controller;
  final String reelID;

  @override
  State<OptimizedVideoPlayer> createState() => _OptimizedVideoPlayerState();
}

class _OptimizedVideoPlayerState extends State<OptimizedVideoPlayer> with TickerProviderStateMixin {
  late AnimationController _loadingController;

  bool _isBuffering = false;
  bool _isPlaying = false;
  bool _showPlayPauseOverlay = false;
  bool _isDisposed = false;
  bool _hasStartedPlaying = false; // Track if video has started playing at least once

  VideoPlayerController? _oldController;
  String? _currentVideoId;
  Key _playerKey = UniqueKey();
  
  // Timer to hide buffering indicator after a timeout
  // This prevents showing buffering indefinitely for cached videos
  Timer? _bufferingTimeoutTimer;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _oldController = widget.controller;
    _currentVideoId = widget.reelID;
    _addControllerListener();
    
    // If controller is already initialized, hide buffering after a short delay
    if (widget.controller?.value.isInitialized ?? false) {
      _startBufferingTimeout(200); // Short timeout for initialized controllers
    }
  }

  @override
  void didUpdateWidget(OptimizedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool videoIdChanged = widget.reelID != _currentVideoId;
    final bool controllerChanged = widget.controller != _oldController;

    if (videoIdChanged || controllerChanged) {
      // Cancel any existing buffering timeout
      _bufferingTimeoutTimer?.cancel();
      
      // Reset playback tracking for new video
      _hasStartedPlaying = false;
      
      // First remove the old listener to prevent memory leaks
      _oldController?.removeListener(_onControllerUpdate);
      
      // If we're changing controllers, ensure the old one is muted
      // This prevents audio leakage when switching between videos
      if (_oldController != null && 
          _oldController != widget.controller && 
          _oldController!.value.isInitialized) {
        // Immediately mute the old controller to prevent audio overlap
        _oldController!.setVolume(0.0);
        
        // Also pause the old controller to ensure it stops playing
        if (_oldController!.value.isPlaying) {
          _oldController!.pause();
        }
      }
      
      // Update references immediately to prevent delays
      _oldController = widget.controller;
      _currentVideoId = widget.reelID;
      _playerKey = UniqueKey();
      
      // Add listener to the new controller
      _addControllerListener();

      // For cached videos, we want to minimize the buffering indicator
      // Only show buffering if the controller is not initialized yet
      final isInitialized = widget.controller?.value.isInitialized ?? false;
      final shouldBuffer = !isInitialized;
      
      if (mounted && _isBuffering != shouldBuffer) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isBuffering = shouldBuffer;
            });
          }
        });
      }
      
      // If controller is initialized, hide buffering after a short delay
      // This ensures we don't show buffering for cached videos
      if (isInitialized) {
        _startBufferingTimeout(50); // Very short timeout for initialized controllers
      } else {
        // For non-initialized controllers, use a longer timeout
        _startBufferingTimeout(1000); // 1 second timeout for non-initialized controllers
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Stop the animation controller before disposing to prevent animation errors
    _loadingController.stop();
    _loadingController.dispose();
    _oldController?.removeListener(_onControllerUpdate);
    _oldController = null;
    _bufferingTimeoutTimer?.cancel();
    super.dispose();
  }

  // Start a timer to hide buffering indicator after a timeout
  void _startBufferingTimeout(int milliseconds) {
    _bufferingTimeoutTimer?.cancel();
    _bufferingTimeoutTimer = Timer(Duration(milliseconds: milliseconds), () {
      if (mounted && !_isDisposed) {
        setState(() => _isBuffering = false);
      }
    });
  }

  void _addControllerListener() {
    final controller = widget.controller;
    if (controller != null) {
      // For cached videos, only show buffering if not initialized
      _isBuffering = !controller.value.isInitialized;
      _isPlaying = controller.value.isPlaying;
      controller.addListener(_onControllerUpdate);
      
      // If controller is already initialized, hide buffering indicator
      // This is important for cached videos that load quickly
      if (controller.value.isInitialized) {
        // Use a very short delay to allow the UI to render first
        _startBufferingTimeout(50);
      } else {
        // For non-initialized controllers, use a longer timeout
        _startBufferingTimeout(1000);
      }
    }
  }

  void _onControllerUpdate() {
    if (!mounted || _isDisposed) return;

    final controller = widget.controller;
    if (controller == null) return;

    if (widget.reelID != _currentVideoId) return;

    if (controller.value.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isBuffering = false);
      });
      return;
    }

    final isBuffering = controller.value.isBuffering;
    final isPlaying = controller.value.isPlaying;
    final position = controller.value.position;
    final duration = controller.value.duration;
    final isInitialized = controller.value.isInitialized;

    // Track if video has started playing at least once
    if (isPlaying && !_hasStartedPlaying) {
      _hasStartedPlaying = true;
    }

    // Enhanced buffering detection logic for cached videos
    // For cached videos, we want to minimize showing the buffering indicator
    
    // 1. If the video is playing, don't show buffering indicator
    // This is the most important case - once playback starts, never show buffering
    bool shouldShowBuffering = false;
    
    // 2. Only show buffering in specific cases:
    // - When video is not initialized yet
    // - When video is actually buffering AND not playing AND at position zero
    //   (initial buffering only, not mid-playback buffering)
    if (!isInitialized) {
      shouldShowBuffering = true;
      // Start a timeout to hide buffering indicator even if initialization takes time
      _startBufferingTimeout(1000);
    } else if (isBuffering && !isPlaying && !_hasStartedPlaying) {
      // Only show buffering indicator during initial load and if video hasn't played yet
      // For cached videos, this should be very brief
      shouldShowBuffering = position == Duration.zero;
      
      // If we have a valid duration, we're probably ready to play
      // This helps with cached videos that might still report buffering
      if (duration.inMilliseconds > 0) {
        // If we've loaded the duration, we're likely ready to play
        // Start a short timeout to hide buffering indicator
        _startBufferingTimeout(200);
      }
    }
    
    // 3. If video has started playing at any point, don't show buffering again
    // This ensures a smooth experience for cached videos
    if (_hasStartedPlaying || position > Duration.zero) {
      shouldShowBuffering = false;
    }

    if (_isBuffering != shouldShowBuffering || _isPlaying != isPlaying) {
      // Use a safe setState pattern to prevent calling setState after dispose
      if (!_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) {
            setState(() {
              _isBuffering = shouldShowBuffering;
              _isPlaying = isPlaying;
            });
          }
        });
      }
    }
  }

  void _togglePlayPause() async {
    final controller = widget.controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (_isDisposed) return;
    
    setState(()=> _showPlayPauseOverlay = true);

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      // When resuming playback, ensure we don't show buffering
      _hasStartedPlaying = true;
      setState(() => _isBuffering = false);
      await controller.play();
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_isDisposed) {
        setState(() => _showPlayPauseOverlay = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller == null) {
      return Center(
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_loadingController),
          child: LoadingWidget(),
        ),
      );
    }

    // For non-initialized controllers, show loading but with a timeout
    if (!controller.value.isInitialized) {
      // Start a timeout to hide buffering indicator even if initialization takes time
      _startBufferingTimeout(1000);
      
      return Center(
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_loadingController),
          child: LoadingWidget(),
        ),
      );
    }

    bool isPortrait = controller.value.size.height > controller.value.size.width;

    // Use a RepaintBoundary to optimize rendering performance
    Widget child = RepaintBoundary(
      child: VideoPlayer(controller),
    );
    
    return GestureDetector(
      onTap: _togglePlayPause,
      key: _playerKey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Optimize video rendering based on orientation
          isPortrait
              ? SizedBox.expand(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio, 
                    child: child
                  )
                )
              : AspectRatio(
                  aspectRatio: controller.value.aspectRatio, 
                  child: child
                ),
          
          // Only show buffering indicator when actually buffering and not after playback has started
          if (_isBuffering && !_hasStartedPlaying)
            LoadingWidget(color: AppColors.purpleColor),
          
          // Only show play/pause overlay when needed
          if (_showPlayPauseOverlay)
            PlayPauseWidget(isPlaying: controller.value.isPlaying)
        ],
      ),
    );
  }
}
