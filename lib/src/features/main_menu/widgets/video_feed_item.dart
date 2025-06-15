import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/bloc_cubit/video_feed_cubit.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/models/user_model.dart';

import 'package:video_player/video_player.dart';

import '../../../app_data.dart';
import '../../../res/app_colors.dart';
import '../../../res/app_constants.dart';
import '../../../res/app_icons.dart';
import '../../../res/app_textstyles.dart';
import '../../../services/user_service.dart';
import '../../../widgets/app_text_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/mood_selecting_scroll_wheel_widget.dart';
import '../../../widgets/post_bookmark_widget.dart';
import '../../../widgets/post_comment_widget.dart';
import '../../../widgets/post_like_widget.dart';
import '../../../widgets/post_share_widget.dart';
import '../profile/remote_user_profile.dart';
import 'optimized_video_player.dart';

class VideoFeedItem extends StatefulWidget {
  const VideoFeedItem({
    super.key,
    required this.reel,
    required this.controller,
  });

  final ReelModel reel;
  final VideoPlayerController? controller;

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> {
  UserModel? _userModel;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          OptimizedVideoPlayer(controller: widget.controller, videoId: widget.reel.reelID),
          Positioned(
            bottom: 80,
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
                                        }else if(snap.connectionState == ConnectionState.waiting){
                                          return Align(
                                              alignment: Alignment.topLeft,
                                              child: LoadingWidget());
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
          ),
          Positioned(
            bottom: 100,
            right: 5,
            child: Column(
              spacing: 10,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: (){
                        String? userName = _userModel?.userName;
                        String? userID = _userModel?.userID;
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context, builder: (ctx){
                          return FractionallySizedBox(
                              heightFactor: 0.75,
                              child: SingleChildScrollView(child: RemoteUserProfileInfoWidget(userName: userName, userID: userID!,)));
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
                PostLikeWidget(reel: widget.reel, iconColor: Colors.white, isReel: true,),
                PostCommentWidget(iconColor: Colors.white, isReel: true, reel: widget.reel,),
                PostBookmarkWidget(reelID: widget.reel.reelID,),
                PostShareWidget( iconColor: Colors.white,),
              ],
            ),
          ),
          StreamBuilder(
              stream: UserService.getCurrentUserStream(),
              builder: (context, snapshot,) {
                if(snapshot.hasData){
                  String mood = snapshot.requireData.mood ?? 'Happy';
                  return Positioned(
                      top: 45,
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
                            // Clear existing feed
                            //Fetch new reels based on the mood
                            context.read<VideoFeedCubit>().onMoodChange(mood: result);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppConstants.appTitle, style: AppTextStyles.headingTextStyle3.copyWith(color: Colors.white),),
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
    );
  }
}
