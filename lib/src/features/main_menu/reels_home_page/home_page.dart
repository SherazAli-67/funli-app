import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';

import '../../../widgets/post_comment_widget.dart';
import '../../../widgets/post_like_widget.dart';
import '../../../widgets/post_share_widget.dart';
class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox.expand(child: CachedNetworkImage(imageUrl: AppIcons.icDummyImgUrl, fit: BoxFit.cover,),),
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  return GestureDetector(
                    onTap: () {
                      // setState(() => isReadMore = !isReadMore);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                              maxHeight: 300,
                            ),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding:
                                const EdgeInsets.only(right: 50, left: 10,bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Sheraz Ali", style: AppTextStyles.subHeadingTextStyle.copyWith(color: Colors.white),),
                                    Text(
                                      "Hey! humari pawrty horhi. 😉#fyp",
                                      // maxLines:
                                      // isReadMore ? 100 : 2,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 120,
          right: 10,
          child: Column(
            spacing: 10,
            children: [
              PostLikeWidget( iconColor: Colors.white, isReel: true,),
              PostCommentWidget(iconColor: Colors.white, isReel: true,),
              PostShareWidget( iconColor: Colors.white,),
            ],
          ),
        ),
      ],
    );
  }
}