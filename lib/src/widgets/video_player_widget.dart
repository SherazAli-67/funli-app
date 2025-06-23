import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/play_pause_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../res/app_constants.dart';
import '../res/app_icons.dart';
import '../res/app_textstyles.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? localPath;
  final String? videoUrl;

  const VideoPlayerWidget({super.key, this.localPath, this.videoUrl});

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  late AnimationController _loadingController;
  bool _isBuffering = false;
  bool _showPlayPauseOverlay = false;
  bool _isDisposed = false;
  Timer? _overlayTimer;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    if (widget.localPath != null) {
      _controller = VideoPlayerController.file(File(widget.localPath!))
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
        });
    } else if (widget.videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
        });
    } else {
      // No video source provided
      _isInitialized = false;
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localPath != widget.localPath || oldWidget.videoUrl != widget.videoUrl) {
      _controller.dispose();
      _isInitialized = false;
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    _loadingController.stop();
    _loadingController.dispose();
    _overlayTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (!_controller.value.isInitialized) return;
    if (_isDisposed) return;

    // Cancel any existing overlay timer
    _overlayTimer?.cancel();
    setState(() => _showPlayPauseOverlay = true);

    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      // When resuming playback, ensure we don't show buffering
      setState(() => _isBuffering = false);
      // Ensure volume is set correctly before playing
      if (_controller.value.volume < 0.1) {
        // If video was muted, keep it muted
        await _controller.setVolume(0.0);
      } else {
        // Otherwise ensure full volume
        await _controller.setVolume(1.0);
      }
      await _controller.play();
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
    if (!_isInitialized) {
      return Center(
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_loadingController),
          child: const LoadingWidget(),
        ),
      );
    }

    bool isPortrait = _controller.value.size.height > _controller.value.size.width;

    // Use a RepaintBoundary to optimize rendering performance
    Widget child = RepaintBoundary(
      child: VideoPlayer(_controller),
    );

    return Scaffold(
      body: GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          alignment: Alignment.center,
          children: [
            isPortrait
                ? SizedBox.expand(child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: child))
                : AspectRatio(aspectRatio: _controller.value.aspectRatio, child: child),
            if (_isBuffering)
              LoadingWidget(color: AppColors.purpleColor),
            if (_showPlayPauseOverlay)
              PlayPauseWidget(isPlaying: _controller.value.isPlaying),

            Positioned(
              top: 55,
              left: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  IconButton(onPressed: (){
                    context.pop();
                  }, icon:SvgPicture.asset(AppIcons.icArrowBack, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),)),
                  Text(AppConstants.appTitle, style: AppTextStyles.headingTextStyle3.copyWith(color: Colors.white),)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
