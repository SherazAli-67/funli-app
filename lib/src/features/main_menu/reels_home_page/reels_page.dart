// screens/reels_screen.dart
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/features/main_menu/profile/remote_user_profile.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/app_text_widget.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:whitecodel_reels/models/video_model.dart';
import 'package:whitecodel_reels/whitecodel_reels.dart';

import '../../../providers/reels_provider.dart';
import '../../../res/app_icons.dart';
import '../../../res/app_textstyles.dart';
import '../../../widgets/mood_selecting_scroll_wheel_widget.dart';
import '../../../widgets/post_comment_widget.dart';
import '../../../widgets/post_like_widget.dart';
import '../../../widgets/post_share_widget.dart';
class ReelsPage extends StatefulWidget {

  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late ScrollController _scrollController;
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final provider = Provider.of<ReelProvider>(context, listen: false);
      provider.fetchReels();

      _scrollController = ScrollController()
        ..addListener(() {
          if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
            provider.fetchReels();
          }
        });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReelProvider>(
      builder: (context, provider, _) {
        final reels = provider.reels;

        if (provider.isLoading && reels.isEmpty) {
          return LoadingWidget();
        }

        if (reels.isEmpty) {
          return const Center(child: Text("No reels available."));
        }

        return SizedBox.expand(
          child: WhiteCodelReels(
              context: context,
              loader: const Center(
                child: CircularProgressIndicator(),
              ),
              // loader: Expanded(child: Text("Loading", style: AppTextStyles.headingTextStyle3.copyWith(color: AppColors.purpleColor),)),
              isCaching: true,
              videoList:
              List.generate(reels.length, (index) => VideoModel(url: reels[index].videoUrl)),
              builder: (context, index, child, videoPlayerController, pageController) {
                bool isReadMore = false;
                ReelModel reel = reels[index];
                StreamController<double> videoProgressController = StreamController<double>();
                videoPlayerController.addListener(() {
                  final position = videoPlayerController.value.position;
                  final duration = videoPlayerController.value.duration;

                  if (position >= duration && pageController.hasClients) {
                    // Move to the next page
                    final nextPage = index + 1;
                    if (nextPage < reels.length) {
                      pageController.animateToPage(
                        nextPage,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }

                  double videoProgress = position.inMilliseconds / duration.inMilliseconds;
                  videoProgressController.add(videoProgress);
                });


                ReelsService.addViewToReel(reelID: reel.reelID);
                bool isPortrait = videoPlayerController.value.size.height > videoPlayerController.value.size.width;

                return Stack(
                  children: [
                    Center(
                      child: isPortrait
                          ? SizedBox.expand(
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
                                  setState(() => isReadMore = !isReadMore);
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
                                                FutureBuilder(future: UserService.getUserByID(userID: reel.userID), builder: (ctx, snap){
                                                  if(snap.hasData && snap.requireData != null){
                                                    _userModel = snap.requireData!;
                                                    return Text(_userModel!.userName, style: AppTextStyles.buttonTextStyle.copyWith(color: Colors.white),);
                                                  }else if(snap.connectionState == ConnectionState.waiting){
                                                    return Align(
                                                        alignment: Alignment.topLeft,
                                                        child: LoadingWidget());
                                                  }

                                                  return const SizedBox();
                                                }),
                                                AppTextWidget(text: reel.caption),
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
                      bottom: 150,
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
                                    backgroundImage: CachedNetworkImageProvider(AppIcons.icDummyImgUrl),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                left: 0,
                                child: FutureBuilder(future: UserService.getIsFollowing(reel.userID), builder: (ctx, snapshot){

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
                                            onPressed: () => UserService.onFollowTap(remoteUID: reel.userID),
                                            icon: SvgPicture.asset(
                                              AppIcons.icAdd, height: 20,))
                                    );
                                  }

                                  return SizedBox();
                                })
                              ),
                            ],
                          ),
                          PostLikeWidget(reel: reel, iconColor: Colors.white, isReel: true,),
                          PostCommentWidget(iconColor: Colors.white, isReel: true, reel: reel,),
                          PostShareWidget( iconColor: Colors.white,),
                        ],
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
                                  onTap: (){
                                    showModalBottomSheet(context: context, builder: (_){
                                      return MoodSelectingScrollWheelWidget(onMoodChange: (mood){
                                        UserService.updateMoodTo(mood);
                                      });
                                    });
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
                );
              }),
        );

      },
    );
  }

  Center _buildCommentWidget() => Center(child: Text("Reels page is set to comment due to development of other pages and to avoid re-built", style: AppTextStyles.bodyTextStyle, textAlign: TextAlign.center,),);
}