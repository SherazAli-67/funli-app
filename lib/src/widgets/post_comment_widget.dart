import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/features/main_menu/reels_home_page/comments_page.dart';
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
          /*showCupertinoSheet(

              context: context, pageBuilder: (_){
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: CommentsPage(),
            );
          });*/
          showModalBottomSheet<void>(
            context: context,
            backgroundColor: Colors.white,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: FractionallySizedBox(
                    heightFactor: 0.8,
                    child: CommentsPage(),
                  ));
            },
          );
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