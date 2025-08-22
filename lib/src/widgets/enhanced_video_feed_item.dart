import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/models/notification_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/services/notifications_service.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:funli_app/src/widgets/like_animation_widget.dart';
import 'package:funli_app/src/widgets/post_comment_widget.dart';
import 'package:funli_app/src/widgets/post_like_widget.dart';
import 'package:funli_app/src/widgets/post_share_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/services/enhanced_video_feed_service.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/play_pause_widget.dart';
import '../app_router/router_enum.dart';
import '../dependancy_injection/dependency_injector.dart';
import '../features/main_menu/profile/remote_user_profile.dart';
import '../res/app_icons.dart';
import '../services/deep_link_service.dart';
import '../services/user_service.dart';
import 'app_text_widget.dart';

/// Enhanced video feed item with optimized performance and seamless playback
class EnhancedVideoFeedItem extends StatefulWidget {
  final ReelModel reel;
  final bool shouldAutoPlay;
  final bool isCurrentItem;
  final VoidCallback? onTap;
  final Function(bool isPlaying)? onPlayStateChanged;
  final bool comingFromHome;
  const EnhancedVideoFeedItem({
    super.key,
    required this.reel,
     this.comingFromHome = false,
    this.shouldAutoPlay = false,
    this.isCurrentItem = false,
    this.onTap,
    this.onPlayStateChanged,
  });

  @override
  State<EnhancedVideoFeedItem> createState() => _EnhancedVideoFeedItemState();
}

class _EnhancedVideoFeedItemState extends State<EnhancedVideoFeedItem>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _showPlayPauseOverlay = false;
  bool _isPlaying = false;
  bool _hasError = false;
  String? _errorMessage;

  Timer? _overlayTimer;
  Timer? _performanceTimer;

  final EnhancedVideoFeedService _videoService = EnhancedVideoFeedService();

  // Performance tracking
  late DateTime _initStartTime;
  int _bufferCount = 0;
  Duration? _totalBufferTime;
  DateTime? _bufferStartTime;

  // Double-tap detection and like animation
  Timer? _tapTimer;
  bool _showLikeAnimation = false;


  UserModel? _userModel;
  bool _reelShareableLinkGenerating = false;
  @override
  bool get wantKeepAlive => widget.isCurrentItem;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStartTime = DateTime.now();

    // Initialize controller when widget becomes current item
    if (widget.isCurrentItem) {
      _initializeController();
    }

    _initUserInfo();
  }

  @override
  void didUpdateWidget(EnhancedVideoFeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle when item becomes current or non-current
    if (widget.isCurrentItem != oldWidget.isCurrentItem) {
      if (widget.isCurrentItem) {
        // Notify service about scroll to video
        _videoService.onScrollToVideo(widget.reel.reelID);
        _initializeController();
      } else {
        // Notify service about scroll away from video
        _videoService.onScrollAwayFromVideo(widget.reel.reelID);
        _pauseVideo();
      }
    }

    // Handle auto-play changes
    if (widget.shouldAutoPlay != oldWidget.shouldAutoPlay) {
      if (widget.shouldAutoPlay && _isInitialized) {
        _playVideo();
      } else if (!widget.shouldAutoPlay) {
        _pauseVideo();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        _pauseVideo();
        break;
      case AppLifecycleState.resumed:
        if (widget.shouldAutoPlay && widget.isCurrentItem) {
          _playVideo();
        }
        break;
      case AppLifecycleState.hidden:
        // Handle hidden state
        break;
    }
  }

  Future<void> _initializeController() async {
    if (_controller != null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Get controller from enhanced service with high priority for current item
      _controller = await _videoService.getController(
        widget.reel.reelID,
        widget.reel.videoUrl,
        shouldPlay: widget.shouldAutoPlay && widget.isCurrentItem,
        priority: widget.isCurrentItem ? 1 : 2,
      );

      if (_controller != null && mounted) {
        // Add listeners for performance monitoring
        _controller!.addListener(_onControllerUpdate);

        // Track initialization time
        final initTime = DateTime.now().difference(_initStartTime);
        debugPrint('Video initialized in ${initTime.inMilliseconds}ms for ${widget.reel.reelID}');

        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _isPlaying = _controller!.value.isPlaying;
        });

        // Notify parent about play state
        widget.onPlayStateChanged?.call(_isPlaying);

        // Start performance monitoring
        _startPerformanceMonitoring();
      }
    } catch (e) {
      debugPrint('Failed to initialize controller: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load video';
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (!mounted || _controller == null) return;

    final value = _controller!.value;
    final wasPlaying = _isPlaying;
    _isPlaying = value.isPlaying;

    // Handle buffering tracking
    if (value.isBuffering && _bufferStartTime == null) {
      _bufferStartTime = DateTime.now();
      _bufferCount++;
    } else if (!value.isBuffering && _bufferStartTime != null) {
      final bufferDuration = DateTime.now().difference(_bufferStartTime!);
      _totalBufferTime = (_totalBufferTime ?? Duration.zero) + bufferDuration;
      _bufferStartTime = null;
    }

    // Handle video completion and ensure looping
    if (value.isInitialized && !value.isBuffering && !value.isPlaying) {
      final position = value.position;
      final duration = value.duration;
      
      // Check if video reached the end (within 1 second of duration)
      if (duration.inMilliseconds > 0 && 
          position.inMilliseconds >= (duration.inMilliseconds - 1000)) {
        // Video completed - restart from beginning
        _restartVideo();
      }
    }

    // Handle error states
    if (value.hasError && !_hasError) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Playback error occurred';
      });
    }

    // Notify parent about play state changes
    if (wasPlaying != _isPlaying) {
      widget.onPlayStateChanged?.call(_isPlaying);
    }

    // Update UI if needed
    if (wasPlaying != _isPlaying) {
      setState(() {});
    }
  }

  /// Restart video from beginning when playback completes
  void _restartVideo() async {
    if (!widget.isCurrentItem || !widget.shouldAutoPlay) return;
    
    try {
      final safeController = await _getSafeController();
      if (safeController != null && safeController.value.isInitialized) {
        // Seek to beginning and play
        await safeController.seekTo(Duration.zero);
        await safeController.play();
        
        debugPrint('Video restarted for ${widget.reel.reelID}');
      }
    } catch (e) {
      debugPrint('Error restarting video ${widget.reel.reelID}: $e');
    }
  }

  void _startPerformanceMonitoring() {
    _performanceTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted || _controller == null) {
        timer.cancel();
        return;
      }

      // Log performance metrics
      final totalBufferMs = _totalBufferTime?.inMilliseconds ?? 0;
      debugPrint('Performance for ${widget.reel.reelID}: '
          'Buffer events: $_bufferCount, '
          'Total buffer time: ${totalBufferMs}ms');
    });
  }

  Future<void> _playVideo() async {
    if (_controller == null) {
      await _initializeController();
      return;
    }

    // Use safe controller access to prevent disposal crashes
    final safeController = await _getSafeController();
    if (safeController != null && safeController.value.isInitialized && !safeController.value.isPlaying) {
      try {
        await safeController.play();
        setState(() {
          _isPlaying = true;
        });
        widget.onPlayStateChanged?.call(true);
      } catch (e) {
        debugPrint('Error playing video ${widget.reel.reelID}: $e');
        // Controller might be disposed, try to reinitialize
        if (e.toString().contains('disposed')) {
          _controller = null;
          _isInitialized = false;
          await _initializeController();
        }
      }
    }
  }

  Future<void> _pauseVideo() async {
    final safeController = await _getSafeController();
    if (safeController != null && safeController.value.isPlaying) {
      try {
        await safeController.pause();
        setState(() {
          _isPlaying = false;
        });
        widget.onPlayStateChanged?.call(false);
      } catch (e) {
        debugPrint('Error pausing video ${widget.reel.reelID}: $e');
        // Handle disposal gracefully
        if (e.toString().contains('disposed')) {
          _controller = null;
          _isInitialized = false;
          setState(() {
            _isPlaying = false;
          });
          widget.onPlayStateChanged?.call(false);
        }
      }
    }
  }

  /// Get safe controller reference from the video service
  Future<VideoPlayerController?> _getSafeController() async {
    try {
      // Try to get a safe controller reference from the service
      final serviceController = await _videoService.getController(
        widget.reel.reelID,
        widget.reel.videoUrl,
        shouldPlay: false,
        priority: 3,
      );
      
      // Update our local reference if needed
      if (serviceController != null && serviceController != _controller) {
        if (_controller != null) {
          _controller!.removeListener(_onControllerUpdate);
        }
        _controller = serviceController;
        _controller!.addListener(_onControllerUpdate);
        _isInitialized = true;
      }
      
      return serviceController;
    } catch (e) {
      debugPrint('Error getting safe controller for ${widget.reel.reelID}: $e');
      return null;
    }
  }

  /// Handle tap detection for both single and double tap
  void _handleTap() {
    final now = DateTime.now();
    
    // Check if this is a potential double tap
    if (_tapTimer?.isActive ?? false) {
      // Double tap detected
      _tapTimer?.cancel();
      _onDoubleTap();
    } else {
      // Start timer for single tap detection
      _tapTimer = Timer(const Duration(milliseconds: 300), () {
        // Single tap confirmed - toggle play/pause
        _togglePlayPause();
      });
    }
    
    // _lastTapTime = now;
  }

  /// Handle double tap - trigger like animation and like the reel
  void _onDoubleTap() async {
    debugPrint('Double tap detected - liking reel ${widget.reel.reelID}');
    
    // Trigger like animation
    _triggerLikeAnimation();
    
    // Like the reel using the same logic as PostLikeWidget
    await _likeReel();
  }

  /// Trigger the like animation
  void _triggerLikeAnimation() {
    if (!mounted) return;
    
    setState(() {
      _showLikeAnimation = true;
    });
    
    // Hide animation after duration
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showLikeAnimation = false;
        });
      }
    });
  }

  /// Like the reel using the existing service
  Future<void> _likeReel() async {
    try {
      // Get current like status
      final likedUsers = await ReelsService.getReelLikes(reelID: widget.reel.reelID).first;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      
      if (currentUserId == null) return;
      
      final isCurrentlyLiked = likedUsers.contains(currentUserId);
      
      // Only like if not already liked (prevent double-liking)
      if (!isCurrentlyLiked) {
        await ReelsService.addLikeToReel(reelID: widget.reel.reelID, isRemove: false);
        
        // Send notification if it's not the user's own reel
        if (widget.reel.userID != currentUserId) {
          await NotificationsService.sendNotificationToUser(
            receiverID: widget.reel.userID,
            reelID: widget.reel.reelID,
            description: "Liked your video",
            notificationType: NotificationType.like,
          );
        }
        
        debugPrint('Reel liked successfully via double tap');
      } else {
        debugPrint('Reel already liked - skipping');
      }
    } catch (e) {
      debugPrint('Error liking reel: $e');
    }
  }

  void _togglePlayPause() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    // Cancel any existing overlay timer
    _overlayTimer?.cancel();

    // Show overlay
    setState(() {
      _showPlayPauseOverlay = true;
    });

    // Toggle playback
    if (_controller!.value.isPlaying) {
      await _pauseVideo();
    } else {
      await _playVideo();
    }

    // Hide overlay after delay
    _overlayTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showPlayPauseOverlay = false;
        });
      }
    });

    // Handle tap callback
    widget.onTap?.call();
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_isLoading || !_isInitialized || _controller == null) {
      return _buildLoadingWidget();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player with optimized rendering
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: RepaintBoundary(
              child: VideoPlayer(_controller!),
            ),
          ),
        ),

        // Buffering indicator
        if (_controller!.value.isBuffering)
          Center(
            child: LoadingWidget(color: AppColors.purpleColor),
          ),

        // Play/Pause overlay
        if (_showPlayPauseOverlay)
          Center(
            child: PlayPauseWidget(isPlaying: _isPlaying),
          ),

        // Like animation overlay
        if (_showLikeAnimation)
          Center(
            child: LikeAnimationWidget(),
          ),

        // Performance debug overlay (only in debug mode)
        /*if (kDebugMode)
          _buildDebugOverlay(),*/

        _buildUserNameCaptionWidget(),
        _buildLikeCommentsIcon(context),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: LoadingWidget(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white70,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Video unavailable',
              style: AppTextStyles.smallTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _controller = null;
                  _isInitialized = false;
                });
                _initializeController();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /*Widget _buildDebugOverlay() {
    return Positioned(
      top: 40,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ID: ${widget.reel.reelID.substring(0, 8)}...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            Text(
              'Buffers: $_bufferCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            Text(
              'Buffer Time: ${_totalBufferTime?.inMilliseconds ?? 0}ms',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            if (_controller != null)
              Text(
                'Position: ${_controller!.value.position.inSeconds}s',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }*/

  Positioned _buildUserNameCaptionWidget() {
    return Positioned(
      bottom:  80,
      left: 0,
      right: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatefulBuilder(
            builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  // setState(() => isReadMore = !isReadMore);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          maxHeight: 300,
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding:
                            const EdgeInsets.only(right: 50, left: 10,bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(_userModel != null)
                                  Text(
                                    _userModel!.userName,
                                    style: AppTextStyles
                                        .buttonTextStyle
                                        .copyWith(
                                        color: Colors.white, fontWeight: FontWeight.w700),),
                                AppTextWidget(text: widget.reel.caption,),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Positioned _buildLikeCommentsIcon(BuildContext context) {
    return Positioned(
      bottom: 85,
      right: 5,
      child: Column(
        spacing: 7,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: (){
                  String? userName = _userModel?.userName;
                  if(widget.reel.userID == FirebaseAuth.instance.currentUser!.uid){
                    context.push(RouterEnum.remoteUserProfileView.routeName, extra: {
                      'userID' : widget.reel.userID,
                      'userName' : userName,
                      'profilePicture' : _userModel?.profilePicture
                    });
                    return;
                  }
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context, builder: (ctx){
                    return FractionallySizedBox(
                        heightFactor: 0.75,
                        child: SingleChildScrollView(
                            child: RemoteUserProfileInfoWidget(userName: userName, userID: widget.reel.userID,)));
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      shape: BoxShape.circle
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: CachedNetworkImageProvider(_userModel != null ? _userModel!.profilePicture ?? AppIcons.icDummyImgUrl: AppIcons.icDummyImgUrl),
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: StreamBuilder(stream: UserService.getIsFollowingStream(widget.reel.userID), builder: (ctx, snapshot){
                    if(snapshot.hasData){
                      bool isFollowing = snapshot.requireData;
                      return Container(
                          decoration: BoxDecoration(
                              color: AppColors.deepPurpleColor,
                              shape: BoxShape.circle
                          ),
                          child: GestureDetector(
                              // padding: EdgeInsets.zero,
                              // style: const ButtonStyle(
                              //   tapTargetSize: MaterialTapTargetSize.shrinkWrap,),
                              onTap: () {
                                bool isPrivateAccount = false;
                                String userName = '';
                                if(_userModel != null){
                                  isPrivateAccount = _userModel!.visibility  == ProfileVisibility.followersOnly;
                                  userName = _userModel!.userName;
                                }
                                UserService.onFollowTap(remoteUID: widget.reel.userID, userName: userName, isPrivateAccount: isPrivateAccount);
                              },
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: isFollowing ? Icon(Icons.done_rounded, color: Colors.white, size: 20,) :  SvgPicture.asset(AppIcons.icAdd, height: 15,),
                              ))
                      );
                    }

                    return SizedBox();
                  })
              ),
            ],
          ),
          PostLikeWidget(reel: widget.reel, iconColor: Colors.white, isReel: true,),
          PostCommentWidget(iconColor: Colors.white, isReel: true, reel: widget.reel,comingFromHome: widget.comingFromHome,),
          PostShareWidget(iconColor: Colors.white, reel: widget.reel, onShareTap: _onShareTap),
          // IconButton(onPressed: _onMoreTap, icon: Icon(Icons.more_horiz, color: Colors.white,))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        GestureDetector(
          onTap: _handleTap,
          child: Container(
            color: Colors.black,
            child: _buildVideoPlayer(),
          ),
        ),
        if(_reelShareableLinkGenerating)
          Container(
              color: Colors.black45,
              child: LoadingWidget())
      ],
    );
  }

  void _onShareTap()async{
    setState(() => _reelShareableLinkGenerating = true);
    final deepLink = await getIt<DeepLinkService>().generateDeepLink(widget.reel.reelID, widget.reel.thumbnailUrl!);
    SharePlus.instance.share(
        ShareParams(text: 'Check out this reel on FUNLI: $deepLink')
    );
    setState(() => _reelShareableLinkGenerating = false);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overlayTimer?.cancel();
    _performanceTimer?.cancel();
    _tapTimer?.cancel(); // Clean up double-tap timer

    // Remove controller listener and release controller reference through service
    if (_controller != null) {
      _controller!.removeListener(_onControllerUpdate);
      // Notify service to release controller reference
      _videoService.releaseController(widget.reel.reelID);
    }

    super.dispose();
  }

  void _initUserInfo() async{
   _userModel = await UserService.getUserByID(userID: widget.reel.userID);
   if(_userModel != null){
     debugPrint("User found not null and profile: ${_userModel!.profilePicture}");
     setState(() {});
   }
  }
}
