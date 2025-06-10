import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:funli_app/src/widgets/gradient_icon.dart';

class PostBookmarkWidget extends StatelessWidget{
  final String reelID;
  const PostBookmarkWidget({super.key, required this.reelID});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ReelsService.getIsBookmarked(reelID: reelID),
        builder: (ctx, snapshot) {
          if(snapshot.hasData){
            bool isBookmarked = snapshot.requireData;

            return IconButton(onPressed: (){
              ReelsService.toggleBookmark(reelID: reelID, isRemoval: isBookmarked);
            }, icon: isBookmarked ? GradientIcon(icon: Icons.bookmark_rounded, size: 30, gradient: AppGradients.primaryGradient) : Icon(Icons.bookmark_rounded, color: Colors.white, size: 30,) );
          }
          return const SizedBox();
        });
  }

}