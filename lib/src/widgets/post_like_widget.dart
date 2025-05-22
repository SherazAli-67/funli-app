import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:like_button/like_button.dart';

class PostLikeWidget extends StatelessWidget{
  final Color iconColor;
  final bool isReel;
  const PostLikeWidget({super.key, this.iconColor = Colors.grey, this.isReel = false});
  @override
  Widget build(BuildContext context) {
    return LikeButton(
      size: 35,
      mainAxisAlignment: MainAxisAlignment.start,
      circleSize: 24,
      isLiked: false,
      padding: EdgeInsets.zero,
      likeCount: 999,
      onTap: (isLiked)async{
        // await PostsService.likePost(post: post, isRemove: isLiked);
        return !isLiked;
      },
      countPostion: isReel ? CountPostion.bottom : CountPostion.right,
      likeBuilder: (isLiked){
        return  SvgPicture.asset(
          AppIcons.icLike,
          colorFilter: ColorFilter.mode(isLiked
              ? AppColors.purpleColor : iconColor, BlendMode.srcIn),
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
            style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white),
          ),
        );
      },
    );
   /* return StreamBuilder(
        stream: PostsService.getPostLikedUsers(postID: post.postID),
        builder: (ctx, snapshot) {
          if(snapshot.hasData){
            List<UserModel> users = snapshot.requireData;
            return LikeButton(
              size: 45,
              mainAxisAlignment: MainAxisAlignment.start,
              circleSize: 24,
              isLiked: getIsLiked(users),
              likeCount: users.length,
              onTap: (isLiked)async{
                await PostsService.likePost(post: post, isRemove: isLiked);
                return !isLiked;
              },
              countPostion: isReel ? CountPostion.bottom : CountPostion.right,
              likeBuilder: (isLiked){
                return  Icon(
                  Icons.thumb_up,
                  color: isLiked
                      ? primaryColor : iconColor,
                  size: 25,
                );
              },
              countBuilder: (_, isSelected, text){
                return text == '0' ? const SizedBox(): IconButton(
                  onPressed: (){},
                  icon: isSelected
                      ? Text(
                    text,
                    style: smallTextStyle.copyWith(
                        fontFamily: giloryFontFamily,
                        color: primaryColor),
                  )
                      : Text(
                    text,
                    style: smallTextStyle.copyWith(
                        fontFamily: giloryFontFamily),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        });*/
  }

 /* bool getIsLiked(List<UserModel> favorites) {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    return favorites.where((favByUser)=> favByUser.userID == userID).isNotEmpty;
  }*/
}