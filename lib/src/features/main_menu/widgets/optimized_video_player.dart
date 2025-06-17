import 'package:flutter/material.dart';
import 'package:funli_app/src/widgets/play_pause_widget.dart';
import 'package:video_player/video_player.dart';

class OptimizedVideoPlayer extends StatefulWidget {
  const OptimizedVideoPlayer({
    super.key,
    required this.controller,
    required this.videoId,
  });

  final VideoPlayerController? controller;
  final String videoId;

  @override
  State<OptimizedVideoPlayer> createState() => _OptimizedVideoPlayerState();
}

class _OptimizedVideoPlayerState extends State<OptimizedVideoPlayer>
    with TickerProviderStateMixin {
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
    _currentVideoId = widget.videoId;
    _addControllerListener();
  }

  @override
  void didUpdateWidget(OptimizedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool videoIdChanged = widget.videoId != _currentVideoId;
    final bool controllerChanged = widget.controller != _oldController;

    if (videoIdChanged || controllerChanged) {
      _oldController?.removeListener(_onControllerUpdate);
      _oldController = widget.controller;
      _currentVideoId = widget.videoId;
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

    if (widget.videoId != _currentVideoId) return;

    if (controller.value.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isBuffering = false);
      });
      return;
    }

    final isBuffering = controller.value.isBuffering;
    final isPlaying = controller.value.isPlaying;

    bool shouldShowBuffering = isBuffering;
    if ((isPlaying && controller.value.position > Duration.zero) ||
        (controller.value.position > Duration.zero &&
            controller.value.duration.inMilliseconds > 0)) {
      shouldShowBuffering = false;
    }

    if (_isBuffering != shouldShowBuffering || _isPlaying != isPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isBuffering = shouldShowBuffering;
            _isPlaying = isPlaying;
          });
        }
      });
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
          turns: Tween(begin: 0.0, end: 1.0).animate(_loadingController),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    bool isPortrait = controller.value.size.height > controller.value.size.width;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Center(
        key: _playerKey,
        child: isPortrait
            ? SizedBox.expand(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: _buildVideoPlayerStack(controller),
          ),
        )
            : AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: _buildVideoPlayerStack(controller),
        ),
      ),
    );
  }

  Widget _buildVideoPlayerStack(VideoPlayerController controller) {
    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(controller),
        if (_isBuffering)
          const Center(child: CircularProgressIndicator()),
        if (_showPlayPauseOverlay)
          PlayPauseWidget(isPlaying: controller.value.isPlaying)
          /*ScaleTransition(
            scale: _iconScaleAnimation,
            child: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 80,
              color: Colors.white70,
            ),
          ),*/
      ],
    );
  }
}