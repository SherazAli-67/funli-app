import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/features/main_menu/reels_home_page/comments_page.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/reels_service.dart';

class PostCommentWidget extends StatelessWidget{
  final Color iconColor;
  final bool isReel;
  final String reelID;
  const PostCommentWidget({super.key, required this.reelID,  this.iconColor = Colors.grey, this.isReel = false});
  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: ReelsService.getReelCommentCount(reelID: reelID),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return _buildCommentWidget(context, totalComments: snapshot.requireData);
        }
        return _buildCommentWidget(context, totalComments: 0);
      }
    );
  }

  Column _buildCommentWidget(BuildContext context, {required int totalComments}) {
    return Column(
          children: [
            GestureDetector(onTap: (){

              showModalBottomSheet<void>(
                context: context,
                backgroundColor: Colors.white,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: FractionallySizedBox(
                        heightFactor: 0.8,
                        child: CommentsPage(reelID: reelID,),
                      ));
                },
              );
            }, child: SvgPicture.asset(AppIcons.icComment,
              colorFilter:  ColorFilter
                  .mode(
                  iconColor, BlendMode.srcIn),),

            ),
            if(totalComments != 0)
              Text( "$totalComments", style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white),)
          ],
        );
  }
}