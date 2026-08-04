import 'package:flutter/material.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/widgets/liquid_glass_icon_widget.dart';
import '../res/app_textstyles.dart';
import '../services/reels_service.dart';

class PostShareWidget extends StatelessWidget{
  final Color iconColor;
  final ReelModel reel;
  final VoidCallback onShareTap;
  const PostShareWidget({super.key, required this.onShareTap, this.iconColor = Colors.grey, required this.reel});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ReelsService.getReelShareCount(reelID: reel.reelID),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return _buildShareWidgetWidget(context, totalShares: snapshot.requireData);
          }
          return _buildShareWidgetWidget(context, totalShares: 0);
        }
    );
    /*return Column(
      children: [
        GestureDetector(
          onTap: onShareTap,
          child: SvgPicture.asset(
            AppIcons.icShare,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ],
    );*/
  }

  Column _buildShareWidgetWidget(BuildContext context, {required int totalShares}) {
    return Column(
      children: [
       LiquidGlassIconWidget(icon: AppIcons.icShare,),

        if(totalShares != 0)
          IconButton(
              onPressed: null,
              icon: Text( "$totalShares", style: AppTextStyles.regularTextStyle.copyWith(color: Colors.white),))
      ],
    );
  }
}
