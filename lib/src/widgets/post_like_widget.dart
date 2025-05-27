import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:like_button/like_button.dart';

class PostLikeWidget extends StatelessWidget{
  final Color iconColor;
  final bool isReel;
  final String icon;
  final String reelID;
  const PostLikeWidget({super.key, required this.reelID, this.icon = AppIcons.icLike, this.iconColor = Colors.grey, this.isReel = false});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ReelsService.getReelLikes(reelID: reelID),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          // debugPrint("Count found: ${snapshot.requireData.length}");
          return _buildLikeButton(snapshot.requireData);
        }
        
        return _buildLikeButton([]);
      }
    );
  }

  Widget _buildLikeButton(List<String> likedUsers) {
    bool isLiked = likedUsers.contains(FirebaseAuth.instance.currentUser!.uid);
    return LikeButton(
          size: 35,
          mainAxisAlignment: MainAxisAlignment.start,
          circleSize: 24,
          isLiked: isLiked,
          padding: EdgeInsets.zero,
          likeCount: likedUsers.length,
          onTap: (isLiked)async{
            await ReelsService.addLikeToReel(reelID: reelID, isRemove: isLiked);
            return !isLiked;
          },
          countPostion: isReel ? CountPostion.bottom : CountPostion.right,
          likeBuilder: (isLiked){
            return isLiked ? SvgPicture.asset(AppIcons.icLikedIcon): SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            );
          },
          countBuilder: (_, isSelected, text){
            return text == '0' ? const SizedBox(): IconButton(
              onPressed: (){},
              icon: isSelected
                  ? Text(
                text,
                style: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.purpleColor),
              )
                  : Text(
                text,
                style: AppTextStyles.bodyTextStyle.copyWith(color: iconColor),
              ),
            );
          },
        );
  }

}