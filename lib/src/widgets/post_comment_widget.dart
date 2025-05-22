import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';

class PostCommentWidget extends StatelessWidget{
  final Color iconColor;
  final bool isReel;
  const PostCommentWidget({super.key,  this.iconColor = Colors.grey, this.isReel = false});
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        IconButton(onPressed: (){
          // showMaterialModalBottomSheet(context: context, builder: builder)
        }, icon: SvgPicture.asset(AppIcons.icComment,
          colorFilter:  ColorFilter
              .mode(
              iconColor, BlendMode.srcIn),)),
        Text('100k', style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white),)
      ],
    );
   /* return StreamBuilder(
        stream: PostsService.getPostCommentCount(postID: post.postID),
        builder: (ctx, snapshot) {
          if(snapshot.hasData){
            return isReel ?  Column(
              children: [
                IconButton(onPressed: (){
                  // showMaterialModalBottomSheet(context: context, builder: builder)
                  showCupertinoModalBottomSheet(context: context, builder: (_)=> CommentsPage(postID: post.postID,));
                }, icon: SvgPicture.asset(AppIcons.icComment,
                  colorFilter:  ColorFilter
                      .mode(
                      iconColor, BlendMode.srcIn),)),
                Text(snapshot.requireData.toString(), style: smallTextStyle,)
              ],
            ) :  Row(
              children: [
                IconButton(onPressed: (){
                  // showMaterialModalBottomSheet(context: context, builder: builder)
                  showCupertinoModalBottomSheet(context: context, builder: (_)=> CommentsPage(postID: post.postID,));
                }, icon: SvgPicture.asset(icMessage,
                  colorFilter:  ColorFilter
                      .mode(
                      iconColor, BlendMode.srcIn),)),
                Text(snapshot.requireData.toString(), style: smallTextStyle,)
              ],
            );
          }

          return const SizedBox();
        });*/
  }
}