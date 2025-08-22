import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/widgets/reel_likes_count.dart';

import '../models/reel_model.dart';
import '../models/user_model.dart';
import '../res/app_colors.dart';
import '../res/app_icons.dart';
import '../res/app_textstyles.dart';
import '../services/reels_service.dart' show ReelsService;
import '../services/user_service.dart';

class ReelGridItemWidget extends StatelessWidget {
  const ReelGridItemWidget({
    super.key,
    required this.reel,
    required VoidCallback onTap,
    bool showUserName = false
  }) : _onTap = onTap, _showUserName = showUserName;

  final ReelModel reel;
  final VoidCallback _onTap;
  final bool _showUserName;    //if the user coming from drafts then don't show the profile picture and username

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(reel.thumbnailUrl ?? AppIcons.icDefaultThumbnailUrl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
          ),
          if(_showUserName)
          Positioned(
              top: 10,
              left: 5,
              right: 5,
              child: FutureBuilder(future: UserService.getUserByID(userID: reel.userID), builder: (ctx, snapshot){
                if(snapshot.hasData && snapshot.requireData != null){
                  UserModel user = snapshot.requireData!;
                  return Row(
                    spacing: 5,
                    children: [

                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.purpleColor,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 19,
                          backgroundImage: CachedNetworkImageProvider(user.profilePicture ?? AppIcons.icDummyImgUrl),
                        ),
                      ),
                      Expanded(child: Text(user.userName, style: AppTextStyles.smallTextStyle.copyWith(color: Colors.white),))
                    ],
                  );
                }

                return SizedBox();
              })),
          Positioned(
              bottom: 10,
              left: 10,
              right: 0,
              child: Row(
                spacing: 5,
                children: [

                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Center(child: Icon(Icons.play_arrow_rounded, ),),
                  ),

                  Expanded(
                      child: FutureBuilder(future: ReelsService.getReelViewsCount(reelID: reel.reelID),
                          builder: (ctx, snapshot) {
                            if(snapshot.hasData && snapshot.requireData > 0){
                              return ReelLikesCountWidget(count: snapshot.requireData);
                            }

                            return ReelLikesCountWidget();
                          }))
                ],
              ))
        ],
      ),
    );
  }
}