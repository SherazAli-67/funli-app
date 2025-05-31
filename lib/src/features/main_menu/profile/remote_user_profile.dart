import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/features/main_menu/profile/remote_user_profile_page.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/gradient_text_widget.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/profile_info_widget.dart';
import 'package:funli_app/src/widgets/secondary_gradient_btn.dart';

class RemoteUserProfileInfoWidget extends StatelessWidget{
  const RemoteUserProfileInfoWidget(
      {super.key, String? userName, required String userID, String? profilePicture, bool isFromProfilePage = false,})
      : _userID = userID,
        _userName = userName,
        _profilePicture = profilePicture,
        _isFromProfilePage = isFromProfilePage;

  final String? _userName;
  final String _userID;
  final String? _profilePicture;
  final bool _isFromProfilePage;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       if(!_isFromProfilePage)
         Align(
           alignment: Alignment.topRight,
           child: IconButton(
               style: IconButton.styleFrom(
                   backgroundColor: AppColors.lightGreyColor,
                   shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(99)
                   )
               ),
               onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.close)),
         ),
        Column(
          spacing: 16,
          children: [
            ProfileInfoWidget(userID: _userID),
            if(!_isFromProfilePage)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 45,
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: StreamBuilder(stream: UserService.getIsFollowing(_userID), builder: (ctx, snapshot){
                          if(snapshot.hasData){
                            bool isFollowing = snapshot.requireData;
                            return PrimaryBtn(btnText: isFollowing ? "Following" : "Follow",isPrefix: true, icon: AppIcons.icAddUser, onTap: (){}, bgGradient: AppIcons.primaryBgGradient, iconColor: Colors.white,);
                          }

                          return  PrimaryBtn(btnText: "",isPrefix: true, icon: AppIcons.icAddUser, onTap: (){}, bgGradient: AppIcons.primaryBgGradient,);
                        }),
                      ),
                      Expanded(child: SecondaryGradientBtn(btnText: "Message",isPrefix: true, icon: AppIcons.gradientChatIcon, onTap: (){}, )),
                    ],
                  ),
                ),
              ),
            if(!_isFromProfilePage)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("Recent Feels", style: AppTextStyles.headingTextStyle3,)),
                ),
                SizedBox(
                  height: 200,
                  child: FutureBuilder(future: ReelsService.getUserReels(limit: 10), builder: (ctx, snapshot){

                    if(snapshot.hasData){
                      return ListView.builder(
                          itemCount: snapshot.requireData.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: CachedNetworkImage(imageUrl: AppIcons.icDummyImgUrl, fit: BoxFit.cover,),
                            );
                          });
                    }else if(snapshot.connectionState == ConnectionState.waiting){
                      return LoadingWidget();
                    }

                    return SizedBox();
                  }),
                ),
              ],
            ),

            // if(!_isFromProfilePage || !_isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: TextButton(onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> RemoteUserProfilePage(userID: _userID, userName: _userName, profilePicture: _profilePicture,)));
                },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientTextWidget(
                          gradient: AppGradients.primaryGradient,
                          text: "View Complete Profile",
                          textStyle: AppTextStyles.buttonTextStyle.copyWith(
                              fontWeight: FontWeight.w700),),
                        Icon(Icons.navigate_next_rounded, color: AppColors.deepPurpleColor, size: 30,)
                      ],
                    )),
              )
          ],
        )
      ],
    );
  }



}