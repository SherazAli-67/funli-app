import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:funli_app/src/widgets/post_like_widget.dart';

class CommentsPage extends StatelessWidget{
  const CommentsPage({super.key, required String reelID}) : _reelID = reelID;
  final String _reelID;
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
                  stream: ReelsService.getReelCommentCount(reelID: _reelID),
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

          StreamBuilder(stream: ReelsService.getReelsComment(reelID: _reelID), builder: (ctx, snapshot){
            if(snapshot.hasData && snapshot.requireData.isNotEmpty){
              return Expanded(child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (ctx, index){
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        spacing: 10,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(AppIcons.icDummyImgUrl),
                            ),
                            title: Text("Kristen Watson", style: AppTextStyles.tileTitleTextStyle,),
                            trailing: IconButton(
                                onPressed: (){}, icon: SvgPicture.asset(AppIcons.icMore)),
                          ),
                          Text("You're looking absolutely amazing. The apparel looks stunning on you and the combo of you guyz ❤️. Looking forward to see more from you guyz.", style: AppTextStyles.commentTextStyle,),
                          Row(
                            spacing: 20,
                            children: [
                              PostLikeWidget(reelID: _reelID,iconColor: Colors.black, icon: AppIcons.icLikeOutlined,),
                              Text("2 days ago", style: AppTextStyles.captionTextStyle.copyWith(color: AppColors.commentTextColor),),
                              TextButton(onPressed: (){}, child: Text("Reply", style: AppTextStyles.captionTextStyle.copyWith(color: AppColors.commentTextColor),))
                            ],
                          )
                        ],
                      ),
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
                IconButton(onPressed: (){}, icon: SvgPicture.asset(AppIcons.icSendBtn))
              ],
            ),
          )
        ],
      ),
    );
  }

}