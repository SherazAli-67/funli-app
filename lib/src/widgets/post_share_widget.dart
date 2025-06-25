import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../dependancy_injection/dependency_injector.dart';
import '../services/deep_link_service.dart';

class PostShareWidget extends StatelessWidget{
  final Color iconColor;
  final ReelModel reel;

  const PostShareWidget({super.key, this.iconColor = Colors.grey, required this.reel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: () async {
            final deepLink = await getIt<DeepLinkService>().generateDeepLink(reel.reelID, reel.thumbnailUrl!);
            SharePlus.instance.share(
                ShareParams(text: 'Check out this reel on FUNLI: $deepLink')
            );
          },
          icon: SvgPicture.asset(
            AppIcons.icShare,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        // if(snapshot.requireData > 0)
        //   Text("132k", style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white),),
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
