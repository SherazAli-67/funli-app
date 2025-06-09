import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/helpers/time_ago_helper.dart';
import 'package:funli_app/src/models/comment_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/services/comment_service.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/comment_like_widget.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import '../../../res/app_colors.dart';
import '../../../res/app_icons.dart';
import '../../../res/app_textstyles.dart';

class CommentItemWidget extends StatefulWidget {
  const CommentItemWidget({
    super.key,
    required AddCommentModel comment,
    required String reelID,
    required Function(String userName, String commentID) onReplyTap
  }) : _comment = comment, _reelID = reelID, _onReplyTap = onReplyTap;
  final AddCommentModel _comment;
  final String _reelID;

  final Function(String userName, String commentID) _onReplyTap;

  @override
  State<CommentItemWidget> createState() => _CommentItemWidgetState();
}

class _CommentItemWidgetState extends State<CommentItemWidget> {
  bool _showReplies = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoWidget(userID: widget._comment.commentBy, commentText: widget._comment.comment),

        StreamBuilder(stream: CommentService.getCommentsReplyCount(reelID: widget._reelID, commentID: widget._comment.commentID), builder: (ctx, snapshot){
          if(snapshot.hasData && snapshot.requireData > 0){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(!_showReplies)
                TextButton(onPressed: (){
                  _showReplies = true;
                  setState(() { });
                }, child: Text("View ${snapshot.requireData} replies", style: AppTextStyles.bodyTextStyle,)),

                if(_showReplies)
                  Container(
                    height: 300,
                    margin: EdgeInsets.only(left: 20),
                    child: FutureBuilder(future: CommentService.getCommentsReply(reelID: widget._reelID, commentID: widget._comment.commentID), builder: (ctx, snapshot){
                      if(snapshot.hasData){
                        return ListView.builder(
                            itemCount: snapshot.requireData.length,
                            itemBuilder: (ctx, index){
                              AddCommentModel reply = snapshot.requireData[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: _buildUserInfoWidget(userID: reply.commentBy, commentText: reply.comment, isReply: true),
                              );
                            });
                      }else if(snapshot.connectionState == ConnectionState.waiting){
                        return LoadingWidget(color: AppColors.purpleColor,);
                      }

                      return SizedBox();
                    }),
                  )
              ],
            );
          }
          return SizedBox();
        })
      ],
    );
  }

 Widget _buildUserInfoWidget({required String userID, required String commentText,  bool isReply = false}) {
    String userName = '';
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder(future: UserService.getUserByID(userID: userID), builder: (ctx,snapshot){
          if(snapshot.hasData && snapshot.requireData != null){
            UserModel user = snapshot.requireData!;
            userName = user.userName;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.profilePicture ?? AppIcons.icDummyImgUrl),
              ),
              title: Text(user.userName, style: AppTextStyles.tileTitleTextStyle,),
              trailing: IconButton(
                  onPressed: (){}, icon: SvgPicture.asset(AppIcons.icMore)),
            );
          }
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(AppIcons.icDummyImgUrl),
            ),
            title: Text("...", style: AppTextStyles.tileTitleTextStyle,),
            trailing: IconButton(
                onPressed: (){}, icon: SvgPicture.asset(AppIcons.icMore)),
          );
        }),
        Text(commentText, style: AppTextStyles.commentTextStyle,),
        if(!isReply)
          Row(
            spacing: 20,
            children: [
              CommentLikeWidget(reelID: widget._reelID, commentID: widget._comment.commentID),
              Text(DateTimeHelper.timeAgo(widget._comment.dateTime), style: AppTextStyles.captionTextStyle.copyWith(color: AppColors.commentTextColor),),
              TextButton(onPressed: ()=> widget._onReplyTap(userName, widget._comment.commentID), child: Text("Reply", style: AppTextStyles.captionTextStyle.copyWith(color: AppColors.commentTextColor),))
            ],
          ),
      ],
    );
  }
}