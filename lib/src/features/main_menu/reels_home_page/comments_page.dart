import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/main_menu/reels_home_page/comment_item_widget.dart';
import 'package:funli_app/src/models/comment_model.dart';
import 'package:funli_app/src/models/notification_model.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/notifications_service.dart';
import 'package:funli_app/src/services/reels_service.dart';

class CommentsPage extends StatefulWidget{
  const CommentsPage({super.key, required ReelModel reel}) : _reel = reel;
  final ReelModel _reel;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 22),
      child: Column(
        spacing: 14,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder(
                  stream: ReelsService.getReelCommentCount(reelID: widget._reel.reelID),
                  builder: (ctx, snapshot) {
                    if(snapshot.hasData && snapshot.requireData > 0){
                      return Text('Comments (${snapshot.requireData})', style: AppTextStyles.headingTextStyle3,);
                    }
                    return Text('Comments ', style: AppTextStyles.headingTextStyle3,);
                  }),
              IconButton(
                  style: IconButton.styleFrom(
                      backgroundColor: AppColors.lightGreyColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99))
                  ),
                  onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.close))
            ],
          ),

          StreamBuilder(stream: ReelsService.getReelsComment(reelID: widget._reel.reelID), builder: (ctx, snapshot){
            if(snapshot.hasData && snapshot.requireData.isNotEmpty){
              return Expanded(child: ListView.builder(
                  itemCount: snapshot.requireData.length,
                  itemBuilder: (ctx, index){
                    AddCommentModel comment = snapshot.requireData[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: CommentItemWidget(comment: comment, reelID:  widget._reel.reelID)
                    );
                  }));
            }
            return Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Text("No Comments Yet", style: AppTextStyles.headingTextStyle3,),
                Text("Be the first to comment on the reel", style: AppTextStyles.bodyTextStyle,),
              ],
            ));
          }),

          Container(

            decoration: BoxDecoration(
              color: AppColors.commentTextFieldFillColor,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.borderColor)
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      IconButton(onPressed: (){}, icon: Icon(Icons.emoji_emotions_outlined)),
                      Expanded(child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Say something nice...",
                          hintStyle: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400, color: AppColors.commentHintTextColor)
                        ),
                      ))
                    ],
                  ),
                ),
                IconButton(onPressed: ()async{
                  String commentText = _commentController.text.trim();
                  await ReelsService.addCommentToReel(reelID: widget._reel.reelID, commentText: commentText);
                  NotificationsService.sendNotificationToUser(
                      receiverID: widget._reel.userID,
                      reelID: widget._reel.reelID,
                      description: "Leave a comment on your video",
                      notificationType: NotificationType.comment);
                  FocusManager.instance.primaryFocus?.unfocus();
                  _commentController.clear();
                }, icon: SvgPicture.asset(AppIcons.icSendBtn))
              ],
            ),
          )
        ],
      ),
    );
  }
}

