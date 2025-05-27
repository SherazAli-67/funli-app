import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/helpers/time_ago_helper.dart';
import 'package:funli_app/src/models/comment_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/comment_like_widget.dart';
import '../../../res/app_colors.dart';
import '../../../res/app_icons.dart';
import '../../../res/app_textstyles.dart';

class CommentItemWidget extends StatelessWidget {
  const CommentItemWidget({
    super.key,
    required AddCommentModel comment,
    required String reelID
  }) : _comment = comment, _reelID = reelID;
  final AddCommentModel _comment;
  final String _reelID;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder(future: UserService.getUserByID(userID: _comment.commentBy), builder: (ctx,snapshot){
          if(snapshot.hasData && snapshot.requireData != null){
            UserModel user = snapshot.requireData!;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(AppIcons.icDummyImgUrl),
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
        Text(_comment.comment, style: AppTextStyles.commentTextStyle,),
        Row(
          spacing: 20,
          children: [
            CommentLikeWidget(reelID: _reelID, commentID: _comment.commentID),
            Text(DateTimeHelper.timeAgo(_comment.dateTime), style: AppTextStyles.captionTextStyle.copyWith(color: AppColors.commentTextColor),),
            TextButton(onPressed: (){}, child: Text("Reply", style: AppTextStyles.captionTextStyle.copyWith(color: AppColors.commentTextColor),))
          ],
        )
      ],
    );
  }
}