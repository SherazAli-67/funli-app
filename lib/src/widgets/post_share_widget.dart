import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';

class PostShareWidget extends StatelessWidget{
  final Color iconColor;
  const PostShareWidget({super.key, this.iconColor = Colors.grey});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(onTap: ()async{
          debugPrint("On share tap");
        },
            child: SvgPicture.asset(
              AppIcons.icShare,
              colorFilter:  ColorFilter
                  .mode(iconColor, BlendMode.srcIn),)),
        // if(snapshot.requireData > 0)
          Text("132k", style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white),),
      ],
    );
    /*return StreamBuilder(
        stream: PostsService.getPostShareCount(postID: post.postID),
        builder: (ctx, snapshot) {
          if(snapshot.hasData){
            return Row(
              children: [
                IconButton(onPressed: ()async{
                  debugPrint("On share tap");
                  // I will be needing deep link for sharing the content
                  final String dynamicLink = await DeepLinkHelper.generateDynamicLink(post.postID);

                  Share.share('Check out this post: $dynamicLink');
                },
                    icon: SvgPicture.asset(
                      icShare, height: 20,
                      colorFilter:  ColorFilter
                          .mode(iconColor, BlendMode.srcIn),)),
                if(snapshot.requireData > 0)
                  Text(snapshot.requireData.toString(), style: smallTextStyle,)
              ],
            );
          }

          return const SizedBox();
        });*/
  }

}