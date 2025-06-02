import 'package:flutter/material.dart';
import 'package:funli_app/src/features/main_menu/profile/widgets/remote_user_reels_widget.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';

class HashtagReelsPage extends StatelessWidget{
  const HashtagReelsPage({super.key, required String hashtag}): _hashtag = hashtag;
  final String _hashtag;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text("Hashtag", style: AppTextStyles.headingTextStyle3,),
        centerTitle: false,
      ),
      body: SafeArea(child: Column(
        spacing: 20,
        children: [
         ListTile(
           contentPadding: EdgeInsets.symmetric(horizontal: 20),
           title: Text(_hashtag, style: AppTextStyles.buttonTextStyle,),
           subtitle: Text('20k feels', style: AppTextStyles.smallTextStyle.copyWith(color: AppColors.hashtagCountGreyColor),),
           trailing: SizedBox(
               width: 100,
               height: 45,
               child: PrimaryBtn(btnText: "Follow", icon: '', onTap: (){}, bgGradient: AppIcons.primaryBgGradient,)),
         ),
          Expanded(child: RemoteUserReelsWidget(userID: 'sTAMOezkAJPaDTzCqD8zhQAScjA3'))
        ],
      )),
    );
  }

}