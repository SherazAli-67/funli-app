import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:video_player/video_player.dart';

import '../../../widgets/post_comment_widget.dart';
import '../../../widgets/post_like_widget.dart';
import '../../../widgets/post_share_widget.dart';
class ReelItemWidget extends StatelessWidget{
  const ReelItemWidget({super.key, required ReelModel reel, required VideoPlayerController controller,}): _reel = reel, _playerController = controller;
  final ReelModel _reel;
  final VideoPlayerController _playerController;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        /*
        * return Stack(
                children: [
                  Center(
                    child: isPortrait
                        ? SizedBox(
                      height: size.height,
                      child: AspectRatio(
                        aspectRatio: videoPlayerController.value.aspectRatio,
                        child: child,
                      ),
                    )
                        : AspectRatio(
                      aspectRatio: videoPlayerController.value.aspectRatio,
                      child: child,
                    ),
                  ),

                  StreamBuilder(
                    stream: videoProgressController.stream,
                    builder: (context, snapshot) {
                      return Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: SliderComponentShape.noThumb,
                            overlayShape:
                            SliderComponentShape.noOverlay,
                            trackHeight: 2,
                          ),
                          child: Slider(
                            value: (snapshot.data ?? 0).clamp(0.0, 1.0),
                            min: 0.0,
                            max: 1.0,
                            activeColor: AppColors.purpleColor,
                            inactiveColor: Colors.white,

                            onChanged: (value) {
                              final position = videoPlayerController
                                  .value.duration.inMilliseconds *
                                  value;
                              videoPlayerController.seekTo(Duration(
                                  milliseconds: position.toInt()));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
        * */

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
                                    Text("Sheraz Ali", style: AppTextStyles.subHeadingTextStyle.copyWith(color: Colors.white),),
                                    Text(
                                      "Hey! humari pawrty horhi. 😉#fyp",
                                      // maxLines:
                                      // isReadMore ? 100 : 2,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white),
                                    )
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
          bottom: 120,
          right: 10,
          child: Column(
            spacing: 10,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: (){},
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: CachedNetworkImageProvider(AppIcons.icDummyImgUrl),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child:

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.deepPurpleColor,
                        shape: BoxShape.circle
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                          style: const ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: (){}, icon: SvgPicture.asset(AppIcons.icAdd, height: 20,))
                    ),
                  )
                ],
              ),
              PostLikeWidget( iconColor: Colors.white, isReel: true,),
              PostCommentWidget(iconColor: Colors.white, isReel: true,),
              PostShareWidget( iconColor: Colors.white,),
            ],
          ),
        ),
      ],
    );
  }
}