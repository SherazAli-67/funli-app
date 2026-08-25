import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/models/notification_model.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/notifications_service.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:funli_app/src/widgets/liquid_glass_icon_widget.dart';
import 'package:funli_app/src/widgets/reel_liked_users_widget.dart';

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
          return _buildLikeButton(context, snapshot.requireData);
        }
        
        return _buildLikeButton(context, []);
      }
    );
  }

  Widget _buildLikeButton(BuildContext context, List<String> likedUsers) {
    String reelID = reel.reelID;
    bool isLiked = likedUsers.contains(FirebaseAuth.instance.currentUser!.uid);
    return Column(
      children: [
        GestureDetector(
            onTap: (){
              ReelsService.addLikeToReel(reelID: reelID, isRemove: isLiked);
              if(!isLiked){
                NotificationsService.sendNotificationToUser(
                    receiverID: reel.userID,
                    reelID: reelID,
                    description: "Liked your video",
                    notificationType: NotificationType.like);
              }
            },
            child: LiquidGlassIconWidget(icon:AppIcons.icLike, iconColor: isLiked ? Colors.black : Colors.white,)),
        GestureDetector(
            onTap: (){
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ReelLikedCommentUsersWidget(reelID: reelID,),
              );
            },
            child: Text(likedUsers.length.toString(), style: AppTextStyles.regularTextStyle.copyWith(color: isLiked ? Colors.black : Colors.white, fontWeight: .bold),))
      ],
    );
    /*return LikeButton(
          size: 24,
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
            return likedUsers.isEmpty ? const SizedBox():  IconButton(
              onPressed: (){
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ReelLikedCommentUsersWidget(reelID: reelID,),
                );
              },
              icon: isSelected
                  ? GradientTextWidget(
                gradient: AppGradients.primaryGradient,
                text: likedUsers.length.toString(),
                textStyle: AppTextStyles.regularTextStyle.copyWith(color: AppColors.primaryColor),
              )
                  : Text(
                text,
                style: AppTextStyles.regularTextStyle.copyWith(color: iconColor),
              ),
            );
          },
        );*/
  }

}