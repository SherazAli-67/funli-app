
import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_colors.dart';
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
  State<ReelsOptimizedPlayerWidget> createState() => _ReelsOptimizedPlayerWidgetState();
}

class _ReelsOptimizedPlayerWidgetState extends State<ReelsOptimizedPlayerWidget> with TickerProviderStateMixin {
  late AnimationController _loadingController;

  bool _isBuffering = false;
  bool _isPlaying = false;
  bool _showPlayPauseOverlay = false;

  VideoPlayerController? _oldController;
  String? _currentVideoId;
  Key _playerKey = UniqueKey();

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
  }

  @override
  void didUpdateWidget(ReelsOptimizedPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool videoIdChanged = widget.reelID != _currentVideoId;
    final bool controllerChanged = widget.controller != _oldController;

    if (videoIdChanged || controllerChanged) {
      _oldController?.removeListener(_onControllerUpdate);
      _oldController = widget.controller;
      _currentVideoId = widget.reelID;
      _playerKey = UniqueKey();
      _addControllerListener();

      final shouldBuffer = widget.controller?.value.isBuffering ?? false;
      if (mounted && _isBuffering != shouldBuffer) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isBuffering = shouldBuffer;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _oldController?.removeListener(_onControllerUpdate);
    _oldController = null;
    super.dispose();
  }

  void _addControllerListener() {
    final controller = widget.controller;
    if (controller != null) {
      _isBuffering = controller.value.isBuffering;
      _isPlaying = controller.value.isPlaying;
      controller.addListener(_onControllerUpdate);
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;

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

    // Improved buffering detection logic
    // Only show buffering indicator if we're actually buffering AND not playing
    // This prevents the buffering indicator from showing during normal playback
    bool shouldShowBuffering = isBuffering && !isPlaying;

    // If video has started playing, don't show buffering even if technically buffering
    // This creates a smoother user experience
    if (isPlaying && controller.value.position > Duration.zero) {
      shouldShowBuffering = false;
    }

    // If video has loaded some content but isn't playing yet, don't show buffering
    if (!isPlaying &&
        controller.value.position > Duration.zero &&
        controller.value.duration.inMilliseconds > 0) {
      shouldShowBuffering = false;
    }

    if (_isBuffering != shouldShowBuffering || _isPlaying != isPlaying) {
      if (shouldShowBuffering) {
        // Add a short delay before showing buffering indicator to avoid flicker for quick loads
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && controller.value.isBuffering && !controller.value.isPlaying) {
            setState(() {
              _isBuffering = true;
              _isPlaying = isPlaying;
            });
          }
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isBuffering = false;
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

    setState(()=> _showPlayPauseOverlay = true);


    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showPlayPauseOverlay = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: RotationTransition(
          turns: Tween(begin: 0.0, end:
          1.0).animate(_loadingController),
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
              ? SizedBox.expand(child: AspectRatio(aspectRatio: controller.value.aspectRatio, child: child))
              : AspectRatio(aspectRatio: controller.value.aspectRatio, child: child),

          // Only show buffering indicator when actually buffering
          if (_isBuffering)
            Center(
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_loadingController),
                child: const CircularProgressIndicator(color: AppColors.purpleColor),
              ),
            ),

          // Only show play/pause overlay when needed
          if (_showPlayPauseOverlay)
            PlayPauseWidget(isPlaying: controller.value.isPlaying)
        ],
      ),
    );
  }
}