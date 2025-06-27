import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
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
            return ListTile(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              leading: isBookmarked ? GradientIcon(icon: Icons.bookmark_rounded,
                  size: 30,
                  gradient: AppGradients.primaryGradient) : Icon(
                Icons.bookmark_border_rounded, color: Colors.black, size: 30,),
              title: Text(isBookmarked ? 'Saved Feel' : "Save Feel", style: AppTextStyles.buttonTextStyle,),
              onTap: (){
                ReelsService.toggleBookmark(reelID: reelID, isRemoval: isBookmarked);
                Navigator.of(context).pop();
              },
            );
            /*return Card(
              color: Colors.white,
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                leading: isBookmarked ? GradientIcon(icon: Icons.bookmark_rounded,
                    size: 30,
                    gradient: AppGradients.primaryGradient) : Icon(
                  Icons.bookmark_border_rounded, color: Colors.black, size: 30,),
                title: Text(isBookmarked ? 'Saved' : "Save", style: AppTextStyles.buttonTextStyle,),
                onTap: (){
                  ReelsService.toggleBookmark(reelID: reelID, isRemoval: isBookmarked);
                  Navigator.of(context).pop();
                },
              ),
            );*/
          }
          return const SizedBox();
        });
  }

}