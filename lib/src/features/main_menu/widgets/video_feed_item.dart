import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/features/reels_page/reels_optimized_player_widget.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:video_player/video_player.dart';
import '../../../res/app_colors.dart';
import '../../../res/app_icons.dart';
import '../../../res/app_textstyles.dart';
import '../../../services/user_service.dart';
import '../../../widgets/app_text_widget.dart';
import '../../../widgets/post_bookmark_widget.dart';
import '../../../widgets/post_comment_widget.dart';
import '../../../widgets/post_like_widget.dart';
import '../../../widgets/post_share_widget.dart';
import '../profile/remote_user_profile.dart';

class VideoFeedItem extends StatefulWidget {
  const VideoFeedItem({
    super.key,
    this.isComingFromHome = false,
    required this.reel,
    required this.controller,
  });

  final ReelModel reel;
  final VideoPlayerController? controller;
  final bool isComingFromHome;

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> {
  UserModel? _userModel;
  
  // Use a key to force rebuild when controller changes
  Key _playerKey = UniqueKey();
  String? _lastReelId;
  bool _isMuted = false;
  
  @override
  void initState() {
    super.initState();
    _isMuted = widget.reel.isMuted;
    ReelsService.addViewToReel(reelID: widget.reel.reelID);
  }
  
  @override
  void didUpdateWidget(VideoFeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the reel ID changed or controller changed, update the key to force a rebuild
    if (widget.reel.reelID != _lastReelId || 
        widget.controller != oldWidget.controller) {
      _playerKey = UniqueKey();
      _lastReelId = widget.reel.reelID;
      _isMuted = widget.reel.isMuted;
    }
  }
  
  void _toggleMute() {
    if (widget.controller == null || !widget.controller!.value.isInitialized) return;
    
    setState(() {
      _isMuted = !_isMuted;
    });
    
    if (_isMuted) {
      widget.controller!.setVolume(0);
    } else {
      widget.controller!.setVolume(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ReelsOptimizedPlayerWidget(
            key: _playerKey,
            controller: widget.controller,
            reelID: widget.reel.reelID),
        // Use RepaintBoundary to optimize rendering and prevent unnecessary repaints
       /*widget.isComingFromHome ? RepaintBoundary(
          child: OptimizedVideoPlayer(
            key: _playerKey,
            controller: widget.controller, 
            reelID: widget.reel.reelID
          ),
        ) : ReelsOptimizedPlayerWidget(
           key: _playerKey,
           controller: widget.controller,
           reelID: widget.reel.reelID),*/

        _buildUserNameCaptionWidget(),
        _buildLikeCommentsIcon(context),
        _buildMuteButton(),
      ],
    );
  }
  
  Widget _buildMuteButton() {
    return Positioned(
      top: 100,
      right: 16,
      child: GestureDetector(
        onTap: _toggleMute,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isMuted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Positioned _buildUserNameCaptionWidget() {
    return Positioned(
          bottom: widget.isComingFromHome ? 80 : 0,
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
                                    FutureBuilder(future: UserService.getUserByID(userID: widget.reel.userID), builder: (ctx, snap){
                                      if(snap.hasData && snap.requireData != null){
                                        _userModel = snap.requireData!;
                                        return Text(
                                          _userModel!.userName,
                                          style: AppTextStyles
                                              .buttonTextStyle
                                              .copyWith(
                                              color: Colors.white, fontWeight: FontWeight.w700),);
                                      }

                                      return const SizedBox();
                                    }),
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
          bottom: widget.isComingFromHome ? 85 : 0,
          right: 5,
          child: Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: (){
                      String? userName = _userModel?.userName;
                      String? userID = _userModel?.userID;
                      debugPrint("User name: $userName, userID: $userID");
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context, builder: (ctx){
                        return FractionallySizedBox(
                            heightFactor: 0.75,
                            child: SingleChildScrollView(
                                child: RemoteUserProfileInfoWidget(
                                  userName: userName, userID: widget.reel.userID,)));
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
                        backgroundImage: CachedNetworkImageProvider( _userModel != null ? _userModel!.profilePicture ?? AppIcons.icDummyImgUrl: AppIcons.icDummyImgUrl),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: StreamBuilder(stream: UserService.getIsFollowingStream(widget.reel.userID), builder: (ctx, snapshot){

                        if(snapshot.hasData && !snapshot.requireData){
                          return Container(
                              decoration: BoxDecoration(
                                  color: AppColors.deepPurpleColor,
                                  shape: BoxShape.circle
                              ),
                              child: IconButton(
                                  padding: EdgeInsets.zero,
                                  style: const ButtonStyle(
                                    tapTargetSize: MaterialTapTargetSize
                                        .shrinkWrap,
                                  ),
                                  onPressed: () => UserService.onFollowTap(remoteUID: widget.reel.userID, userName: _userModel != null ? _userModel!.userName : ''),
                                  icon: SvgPicture.asset(
                                    AppIcons.icAdd, height: 20,))
                          );
                        }

                        return SizedBox();
                      })
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              PostLikeWidget(reel: widget.reel, iconColor: Colors.white, isReel: true,),
              PostCommentWidget(iconColor: Colors.white, isReel: true, reel: widget.reel,),
              PostBookmarkWidget(reelID: widget.reel.reelID,),
              PostShareWidget( iconColor: Colors.white,),
            ],
          ),
        );
  }
}
