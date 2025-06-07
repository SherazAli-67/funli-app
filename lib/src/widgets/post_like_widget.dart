import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/models/notification_model.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/notifications_service.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:funli_app/src/widgets/gradient_text_widget.dart';
import 'package:like_button/like_button.dart';

class PostLikeWidget extends StatelessWidget{
  final Color iconColor;
  final bool isReel;
  final String icon;
  final ReelModel reel;
  const PostLikeWidget({super.key, required this.reel, this.icon = AppIcons.icLike, this.iconColor = Colors.grey, this.isReel = false});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ReelsService.getReelLikes(reelID: reel.reelID),
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
    String reelID = reel.reelID;
    bool isLiked = likedUsers.contains(FirebaseAuth.instance.currentUser!.uid);
    /*return GestureDetector(
        onTap: ()async{
      await ReelsService.addLikeToReel(reelID: reelID, isRemove: isLiked);
    }, child: Column(
      children: [
        SvgPicture.asset(isLiked ? AppIcons.icLikedIcon : AppIcons.icLike, height: 35,),
        likedUsers.isEmpty ? const SizedBox(): isLiked
            ? GradientTextWidget(
          gradient: AppGradients.primaryGradient,
          text: likedUsers.length.toString(),
          textStyle: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.purpleColor),
        )
            : Text(
          likedUsers.length.toString(),
          style: AppTextStyles.bodyTextStyle.copyWith(color: iconColor),
        )
      ],
    ));*/
    return LikeButton(
          size: 30,
          mainAxisAlignment: MainAxisAlignment.start,
          circleSize: 24,
          isLiked: isLiked,
          padding: EdgeInsets.zero,
          likeCount: likedUsers.length,
          onTap: (isLiked)async{
             ReelsService.addLikeToReel(reelID: reelID, isRemove: isLiked);
             if(!isLiked){
               NotificationsService.sendNotificationToUser(
                   receiverID: reel.userID,
                   reelID: reelID,
                   description: "Liked your video",
                   notificationType: NotificationType.like);
             }
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
            return text == '0' ? const SizedBox():  isSelected
                ? GradientTextWidget(
              gradient: AppGradients.primaryGradient,
              text: likedUsers.length.toString(),
              textStyle: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.purpleColor),
            )
                : Text(
              text,
              style: AppTextStyles.bodyTextStyle.copyWith(color: iconColor),
            );
          },
        );
  }

}