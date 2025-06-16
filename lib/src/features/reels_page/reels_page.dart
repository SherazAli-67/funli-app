/*
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:video_player/video_player.dart';
import 'package:whitecodel_reels/models/video_model.dart';
import 'package:whitecodel_reels/whitecodel_reels.dart';

import '../../loading_shimmers/reels_shimmer_widget.dart';
import '../../models/reel_model.dart';
import '../../models/user_model.dart';
import '../../res/app_icons.dart';
import '../../services/reels_service.dart';
import '../../services/user_service.dart';
import '../../widgets/post_bookmark_widget.dart';
import '../../widgets/post_comment_widget.dart';
import '../../widgets/post_like_widget.dart';
import '../../widgets/post_share_widget.dart';
import '../main_menu/profile/remote_user_profile.dart';

class ReelsPage extends StatefulWidget {
  final List<ReelModel> initialReels;
  final int selectedIndex;
  final DocumentSnapshot? lastDocument;
  final String comingFrom;
  final String? userID;
  final String? tag;
  final String? mood;
  const ReelsPage({
    super.key,
    required this.initialReels,
    required this.selectedIndex,
    this.lastDocument,
    required this.comingFrom,
    this.userID,
    this.mood,
    this.tag
  });

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late List<ReelModel> reels;
  DocumentSnapshot? _lastDocument;
  bool isFetchingMore = false;
  UserModel? _userModel;
  final int _limit = 4;

  bool _hasMore = false;
  @override
  void initState() {
    super.initState();
    reels = [...widget.initialReels];
    _lastDocument = widget.lastDocument;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WhiteCodelReels(
        context: context,
        loader: ReelsShimmerWidget(),
        isCaching: true,
        startIndex: widget.selectedIndex,
        videoList: List.generate(reels.length, (index) => VideoModel(url: reels[index].videoUrl)),
        builder: (context, index, child, videoPlayerController, pageController) {
          final reel = reels[index];
          final videoProgressController = StreamController<double>();

          videoPlayerController.addListener(() {
            final position = videoPlayerController.value.position;
            final duration = videoPlayerController.value.duration;

            if (position >= duration && pageController.hasClients) {
              final nextPage = index + 1;
              if (nextPage < reels.length) {
                pageController.animateToPage(
                  nextPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                _loadMoreReels();
              }
            }

            if (duration.inMilliseconds > 0) {
              final progress = position.inMilliseconds / duration.inMilliseconds;
              videoProgressController.add(progress);
            }
          });

          ReelsService.addViewToReel(reelID: reel.reelID);
          final isPortrait = videoPlayerController.value.size.height > videoPlayerController.value.size.width;

          return Stack(
            children: [
              Center(
                child: isPortrait
                    ? SizedBox.expand(child: AspectRatio(aspectRatio: videoPlayerController.value.aspectRatio, child: child))
                    : AspectRatio(aspectRatio: videoPlayerController.value.aspectRatio, child: child),
              ),
              _buildBottomInfo(reel),
              _buildRightSideActions(reel),
              _buildSlider(videoProgressController, videoPlayerController),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomInfo(ReelModel reel) {
    bool isReadMore = false;

    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTap: () => setState(() => isReadMore = !isReadMore),
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
              child: Padding(
                padding: const EdgeInsets.only(right: 50, left: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: UserService.getUserByID(userID: reel.userID),
                      builder: (ctx, snap) {
                        if (snap.hasData && snap.data != null) {
                          _userModel = snap.data!;
                          return Text(_userModel!.userName, style: AppTextStyles.buttonTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w700));
                        }
                        return const SizedBox();
                      },
                    ),
                    Text(reel.caption, style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRightSideActions(ReelModel reel) {
    return Positioned(
      bottom: 75,
      right: 5,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showUserProfile(reel),
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(
                  _userModel?.profilePicture ?? AppIcons.icDummyImgUrl,
                ),
              ),
            ),
          ),
          PostLikeWidget(reel: reel, iconColor: Colors.white, isReel: true),
          PostCommentWidget(iconColor: Colors.white, isReel: true, reel: reel),
          PostBookmarkWidget(reelID: reel.reelID),
          PostShareWidget(iconColor: Colors.white),
        ],
      ),
    );
  }

  Widget _buildSlider(StreamController<double> controller, VideoPlayerController videoPlayerController) {
    return StreamBuilder(
      stream: controller.stream,
      builder: (context, snapshot) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: SliderComponentShape.noThumb,
              overlayShape: SliderComponentShape.noOverlay,
              trackHeight: 2,
            ),
            child: Slider(
              value: (snapshot.data ?? 0).clamp(0.0, 1.0),
              min: 0.0,
              max: 1.0,
              activeColor: Colors.purple,
              inactiveColor: Colors.white,
              onChanged: (value) {
                final position = videoPlayerController.value.duration.inMilliseconds * value;
                videoPlayerController.seekTo(Duration(milliseconds: position.toInt()));
              },
            ),
          ),
        );
      },
    );
  }

  void _showUserProfile(ReelModel reel) {
    if (_userModel != null) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (ctx) => FractionallySizedBox(
          heightFactor: 0.75,
          child: RemoteUserProfileInfoWidget(
            userName: _userModel!.userName,
            userID: _userModel!.userID,
          ),
        ),
      );
    }
  }

  void _loadMoreReels() {
    if(widget.comingFrom == AppConstants.comingFromUserProfile){
      ReelsService.fetchUserReels(userId: widget.userID!,
          lastDoc: _lastDocument,
          limit: _limit,
          onLastDoc: (doc)=> _lastDocument = doc,
          onHasMore: (hasMore)=> _hasMore = hasMore);
    }else if(widget.comingFrom == AppConstants.comingFromBookmark){
      ReelsService.fetchUserBookmarkedReels(userId: widget.userID!,
          lastDoc: _lastDocument,
          limit: _limit,
          onLastDoc: (doc)=> _lastDocument = doc,
          onHasMore: (hasMore)=> _hasMore = hasMore);
    }else if(widget.comingFrom == AppConstants.comingFromMood){
      ReelsService.fetchReelsByMood(mood: widget.mood!, lastDoc: _lastDocument, limit: _limit,
          onLastDoc: (doc)=> _lastDocument = doc,
          onHasMore: (hasMore)=> _hasMore = hasMore);
    }else if(widget.comingFrom == AppConstants.comingFromSearch){
      ReelsService.fetchMoreReels(lastDoc: _lastDocument,
          limit: _limit,
          onLastDoc: (doc) => _lastDocument = doc,
          onHasMore: (hasMore) => _hasMore = hasMore);
    }
  }


}

*/
