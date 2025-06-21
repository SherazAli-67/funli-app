import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/services/video_audio_manager.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/play_pause_widget.dart';
import 'package:video_player/video_player.dart';

class OptimizedVideoPlayer extends StatefulWidget {
  const OptimizedVideoPlayer({
    super.key,
    required this.controller,
    required this.videoId,
    this.autoPlay = true,
    this.showControls = true,
  });

  final VideoPlayerController? controller;
  final String videoId;
  final bool autoPlay;
  final bool showControls;

  @override
  State<OptimizedVideoPlayer> createState() => _OptimizedVideoPlayerState();
}

class _OptimizedVideoPlayerState extends State<OptimizedVideoPlayer> {
  final _videoManager = VideoAudioManager();
  
  bool _isBuffering = false;
  bool _showPlayPauseOverlay = false;
  bool _hasRegistered = false;
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(OptimizedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.controller != widget.controller || 
        oldWidget.videoId != widget.videoId) {
      // Clean up old controller
      if (oldWidget.controller != null && _hasRegistered) {
        oldWidget.controller!.removeListener(_onControllerUpdate);
        _videoManager.unregisterController(oldWidget.videoId);
        _hasRegistered = false;
      }
      
      // Initialize new controller
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    if (widget.controller != null && _hasRegistered) {
      widget.controller!.removeListener(_onControllerUpdate);
      _videoManager.unregisterController(widget.videoId);
    }
    super.dispose();
  }

  void _initializePlayer() {
    final controller = widget.controller;
    if (controller != null && controller.value.isInitialized) {
      // Register with video manager
      _videoManager.registerController(widget.videoId, controller);
      _hasRegistered = true;
      
      // Add listener
      controller.addListener(_onControllerUpdate);
      _onControllerUpdate(); // Initial update
      
      // Auto-play if requested
      if (widget.autoPlay) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _videoManager.playVideo(widget.videoId);
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    
    final controller = widget.controller;
    if (controller == null) return;
    
    final isBuffering = controller.value.isBuffering;
    final isPlaying = controller.value.isPlaying;
    
    // Only show buffering if video is not playing
    final shouldShowBuffering = isBuffering && !isPlaying;
    
    if (_isBuffering != shouldShowBuffering) {
      setState(() {
        _isBuffering = shouldShowBuffering;
      });
    }
  }

  void _togglePlayPause() async {
    if (!widget.showControls) return;
    
    final controller = widget.controller;
    if (controller == null || !controller.value.isInitialized) return;
    
    setState(() => _showPlayPauseOverlay = true);
    
    if (controller.value.isPlaying) {
      await controller.pause();
      await controller.setVolume(0.0);
    } else {
      // Use the video manager to play this video (which will pause others)
      await _videoManager.playVideo(widget.videoId);
    }
    
    // Hide overlay after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showPlayPauseOverlay = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }
    
    final isPortrait = controller.value.size.height > controller.value.size.width;
    
    return GestureDetector(
      onTap: widget.showControls ? _togglePlayPause : null,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video player
            RepaintBoundary(
              child: Center(
                child: isPortrait
                    ? SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: controller.value.size.width,
                            height: controller.value.size.height,
                            child: VideoPlayer(controller),
                          ),
                        ),
                      )
                    : AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
              ),
            ),
            
            // Buffering indicator
            if (_isBuffering)
              LoadingWidget(color: AppColors.purpleColor),
            
            // Play/pause overlay
            if (_showPlayPauseOverlay && widget.showControls)
              PlayPauseWidget(isPlaying: controller.value.isPlaying),
          ],
        ),
      ),
    );
  }
}
