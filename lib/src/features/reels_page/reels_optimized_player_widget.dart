import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/services/video_audio_manager.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/play_pause_widget.dart';
import 'package:video_player/video_player.dart';

class ReelsOptimizedPlayerWidget extends StatefulWidget {
  const ReelsOptimizedPlayerWidget({
    super.key,
    required this.controller,
    required this.reelID,
  });

  final VideoPlayerController? controller;
  final String reelID;

  @override
  State<ReelsOptimizedPlayerWidget> createState() =>
      _ReelsOptimizedPlayerWidgetState();
}

class _ReelsOptimizedPlayerWidgetState extends State<ReelsOptimizedPlayerWidget> {
  final _videoManager = VideoAudioManager();
  
  bool _isBuffering = false;
  bool _showPlayPauseOverlay = false;
  
  @override
  void initState() {
    super.initState();
    _addControllerListener();
  }

  @override
  void didUpdateWidget(ReelsOptimizedPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.controller != widget.controller || 
        oldWidget.reelID != widget.reelID) {
      oldWidget.controller?.removeListener(_onControllerUpdate);
      _addControllerListener();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _addControllerListener() {
    final controller = widget.controller;
    if (controller != null) {
      controller.addListener(_onControllerUpdate);
      _onControllerUpdate(); // Initial update
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
    final controller = widget.controller;
    if (controller == null || !controller.value.isInitialized) return;
    
    setState(() => _showPlayPauseOverlay = true);
    
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      // Use the video manager to play this video (which will pause others)
      await _videoManager.playVideo(widget.reelID);
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
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
    
    final isPortrait = controller.value.size.height > controller.value.size.width;
    
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player
          RepaintBoundary(
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
          
          // Buffering indicator
          if (_isBuffering)
            LoadingWidget(color: AppColors.purpleColor),
          
          // Play/pause overlay
          if (_showPlayPauseOverlay)
            PlayPauseWidget(isPlaying: controller.value.isPlaying),
        ],
      ),
    );
  }
}
