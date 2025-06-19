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
  bool _isInitialized = false; // Track if controller is initialized

  VideoPlayerController? _oldController;
  String? _currentVideoId;
  Key _playerKey = UniqueKey();
  
  // Timer to hide buffering indicator after a timeout
  // This prevents showing buffering indefinitely for cached videos
  Timer? _bufferingTimeoutTimer;
  
  // Timer to force play after initialization
  Timer? _forcePlayTimer;
  
  // Timer to hide play/pause overlay
  Timer? _overlayTimer;

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
      // Cancel any existing timers
      _bufferingTimeoutTimer?.cancel();
      _forcePlayTimer?.cancel();
      _overlayTimer?.cancel();
      
      // Reset playback tracking for new video
      _hasStartedPlaying = false;
      _isInitialized = false;
      
      // First remove the old listener to prevent memory leaks
      _oldController?.removeListener(_onControllerUpdate);
      
      // If we're changing controllers, ensure the old one is muted and paused
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
        
        // Reset position to beginning for a clean state
        try {
          _oldController!.seekTo(Duration.zero);
        } catch (e) {
          // Ignore seek errors on old controller
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
      _isInitialized = isInitialized;
      final shouldBuffer = !isInitialized;
      
      if (mounted && _isBuffering != shouldBuffer) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) {
            setState(() {
              _isBuffering = shouldBuffer;
            });
          }
        });
      }
      
      // If controller is initialized, hide buffering after a very short delay
      // This ensures we don't show buffering for cached videos
      if (isInitialized) {
        _startBufferingTimeout(10); // Very short timeout for initialized controllers
        
        // For initialized controllers, force play after a short delay
        // This ensures the video starts playing immediately
        if (widget.controller != null && !widget.controller!.value.isPlaying) {
          _forcePlayTimer = Timer(const Duration(milliseconds: 20), () {
            if (mounted && !_isDisposed && widget.controller != null && 
                widget.controller!.value.isInitialized && !widget.controller!.value.isPlaying) {
              widget.controller!.play();
            }
          });
        }
      } else {
        // For non-initialized controllers, use a shorter timeout than before
        // This improves perceived performance
        _startBufferingTimeout(500); // 500ms timeout for non-initialized controllers
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
    _forcePlayTimer?.cancel();
    _overlayTimer?.cancel();
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
      _isInitialized = controller.value.isInitialized;
      _isBuffering = !_isInitialized;
      _isPlaying = controller.value.isPlaying;
      controller.addListener(_onControllerUpdate);
      
      // If controller is already initialized, hide buffering indicator
      // This is important for cached videos that load quickly
      if (_isInitialized) {
        // Use a very short delay to allow the UI to render first
        _startBufferingTimeout(20);
        
        // For initialized controllers, force play after a short delay
        // This ensures the video starts playing immediately
        if (!controller.value.isPlaying) {
          _forcePlayTimer = Timer(const Duration(milliseconds: 20), () {
            if (mounted && !_isDisposed && controller.value.isInitialized && 
                !controller.value.isPlaying) {
              controller.play();
            }
          });
        }
      } else {
        // For non-initialized controllers, use a shorter timeout
        _startBufferingTimeout(500);
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
        if (mounted && !_isDisposed) setState(() => _isBuffering = false);
      });
      return;
    }

    final isBuffering = controller.value.isBuffering;
    final isPlaying = controller.value.isPlaying;
    final position = controller.value.position;
    final duration = controller.value.duration;
    final isInitialized = controller.value.isInitialized;
    
    // Update initialization state
    if (isInitialized && !_isInitialized) {
      _isInitialized = true;
      
      // For newly initialized videos, force play after a short delay
      if (!isPlaying) {
        _forcePlayTimer?.cancel();
        _forcePlayTimer = Timer(const Duration(milliseconds: 20), () {
          if (mounted && !_isDisposed && controller.value.isInitialized && 
              !controller.value.isPlaying) {
            controller.play();
          }
        });
      }
    }

    // Track if video has started playing at least once
    if (isPlaying && !_hasStartedPlaying) {
      _hasStartedPlaying = true;
      
      // Once playback starts, immediately hide buffering indicator
      if (_isBuffering) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) {
            setState(() => _isBuffering = false);
          }
        });
      }
    }

    // Enhanced buffering detection logic for TikTok-like performance
    // For cached videos, we want to minimize showing the buffering indicator
    
    // 1. If the video is playing, never show buffering indicator
    bool shouldShowBuffering = false;
    
    // 2. Only show buffering in specific cases with aggressive timeouts:
    if (!isInitialized) {
      // For non-initialized videos, show buffering but with a short timeout
      shouldShowBuffering = true;
      // Start a timeout to hide buffering indicator even if initialization takes time
      _startBufferingTimeout(500); // Reduced for faster perceived loading
    } else if (isBuffering && !isPlaying && !_hasStartedPlaying) {
      // Only show buffering indicator during initial load and if video hasn't played yet
      // For cached videos, this should be very brief
      shouldShowBuffering = position == Duration.zero;
      
      // If we have a valid duration, we're probably ready to play
      // This helps with cached videos that might still report buffering
      if (duration.inMilliseconds > 0) {
        // If we've loaded the duration, we're likely ready to play
        // Start a very short timeout to hide buffering indicator
        _startBufferingTimeout(50); // Reduced for faster perceived loading
      }
    }
    
    // 3. Never show buffering after playback has started or if we're not at position zero
    // This ensures a smooth experience for cached videos
    if (_hasStartedPlaying || position > Duration.zero) {
      shouldShowBuffering = false;
    }
    
    // 4. If video is playing but still reporting buffering, don't show indicator
    if (isPlaying) {
      shouldShowBuffering = false;
    }
    
    // 5. If video is initialized but not playing, try to play it
    if (isInitialized && !isPlaying && !shouldShowBuffering && _hasStartedPlaying) {
      // Only try to play if we're not already trying to play
      _forcePlayTimer ??= Timer(const Duration(milliseconds: 20), () {
          if (mounted && !_isDisposed && controller.value.isInitialized &&
              !controller.value.isPlaying) {
            controller.play();
          }
          _forcePlayTimer = null;
        });
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
    
    // Cancel any existing overlay timer
    _overlayTimer?.cancel();
    
    setState(()=> _showPlayPauseOverlay = true);

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      // When resuming playback, ensure we don't show buffering
      _hasStartedPlaying = true;
      setState(() => _isBuffering = false);
      
      // Ensure volume is set correctly before playing
      if (controller.value.volume < 0.1) {
        // If video was muted, keep it muted
        await controller.setVolume(0.0);
      } else {
        // Otherwise ensure full volume
        await controller.setVolume(1.0);
      }
      
      // Play the video
      await controller.play();
    }

    // Hide the play/pause overlay after a short delay
    _overlayTimer = Timer(const Duration(milliseconds: 800), () {
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
      _startBufferingTimeout(500); // Reduced for faster perceived loading
      
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
          isPortrait
              ? SizedBox.expand(child: AspectRatio(aspectRatio: controller.value.aspectRatio, child: child))
              : AspectRatio(aspectRatio: controller.value.aspectRatio, child: child),
          /*isPortrait ? SizedBox.expand(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child:VideoPlayer(controller),
            ),
          ): AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),*/
          if (_isBuffering)
            LoadingWidget(color: AppColors.purpleColor,),
          // if (_showPlayPauseOverlay )
          PlayPauseWidget(isPlaying: controller.value.isPlaying)
        ],
      ),
    );
  }
}
