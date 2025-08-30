import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/app_router/bottom_navigation_widget.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/reels_service.dart';

import '../features/main_menu/video_feed_view/comments_page.dart';

class PostCommentWidget extends StatelessWidget{
  final Color iconColor;
  final bool isReel;
  final ReelModel reel;
  final bool comingFromHome;
  const PostCommentWidget(
      {super.key, required this.reel, this.iconColor = Colors
          .grey, this.isReel = false, required this.comingFromHome});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ReelsService.getReelCommentCount(reelID: reel.reelID),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return _buildCommentWidget(context, totalComments: snapshot.requireData);
        }
        return _buildCommentWidget(context, totalComments: 0);
      }
    );
  }

  Column _buildCommentWidget(BuildContext context, {required int totalComments}) {
    return Column(
          children: [
            GestureDetector(onTap: (){
              // Use conditional logic based on comment count
              bool useDraggableSheet = totalComments > 5;
              
              if(comingFromHome){
                scaffoldKey.currentState!.showBottomSheet(
                    backgroundColor: Colors.white,
                    elevation: 1,
                        (ctx)=> useDraggableSheet 
                        ? DraggableScrollableSheet(
                          initialChildSize: 0.7,
                          minChildSize: 0.5,
                          maxChildSize: 0.9,
                          builder: (context, scrollController) => CommentsPage(
                            reel: reel, 
                            comingFromHome: comingFromHome,
                            scrollController: scrollController,
                          ),
                        )
                        : Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: CommentsPage(
                            reel: reel, 
                            comingFromHome: comingFromHome,
                          ),
                        ));
              }else{
                showBottomSheet(
                    backgroundColor: Colors.white,
                    context: context, builder: (ctx){
                  return useDraggableSheet 
                  ? DraggableScrollableSheet(
                    initialChildSize: 0.75,
                    minChildSize: 0.5,
                    maxChildSize: 0.9,
                    builder: (context, scrollController) => CommentsPage(
                      reel: reel, 
                      comingFromHome: comingFromHome,
                      scrollController: scrollController,
                    ),
                  )
                  : Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: CommentsPage(
                      reel: reel, 
                      comingFromHome: comingFromHome,
                    ),
                  );
                });
              }


            },
              child: SvgPicture.asset(AppIcons.icComment,
              colorFilter:  ColorFilter
                  .mode(
                  iconColor, BlendMode.srcIn),),

            ),
            if(totalComments != 0)
              IconButton(
                  onPressed: null,
                  icon: Text( "$totalComments", style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white),))
          ],
        );
  }
}
