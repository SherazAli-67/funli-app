import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/post_like_widget.dart';

class CommentsPage extends StatelessWidget{
  const CommentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 28),
      child: Column(
        spacing: 14,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Comments (204,755)', style: AppTextStyles.headingTextStyle3,),
              IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.lightGreyColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99))
                  ),
                  onPressed: (){}, icon: Icon(Icons.close))
            ],
          ),
          Expanded(child: ListView.builder(
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
                          PostLikeWidget(iconColor: Colors.black, icon: AppIcons.icLikeOutlined,),
                          Text("2 days ago", style: AppTextStyles.captionTextStyle.copyWith(color: AppColors.commentTextColor),),
                          TextButton(onPressed: (){}, child: Text("Reply", style: AppTextStyles.captionTextStyle.copyWith(color: AppColors.commentTextColor),))
                        ],
                      )
                    ],
                  ),
                );
          }))
        ],
      ),
    );
  }

}