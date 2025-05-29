import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/main_menu/profile/remote_user_profile.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';

class RemoteUserProfilePage extends StatelessWidget{
  const RemoteUserProfilePage({
    super.key,
    required String userID,
    String? userName,
    String? profilePicture,
  }): _userID = userID, _userName = userName, _profilePicture = profilePicture;

  final String _userID;
  final String? _userName;
  final String? _profilePicture;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black,)),
        title: Text(_userName ?? '', style: AppTextStyles.headingTextStyle3,),
        centerTitle: false,
        actions: [
          PopupMenuButton(
              padding: EdgeInsets.zero,
              onSelected: (val){},
              position: PopupMenuPosition.under,
              icon: Icon(Icons.more_vert_rounded),
              color: Colors.white,
              itemBuilder: (_){
            return [
              PopupMenuItem(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  value: 1,
                  child: Row(
                    spacing: 12,
                    children: [
                    SvgPicture.asset(AppIcons.icReportUser),
                    Text("Report user", style: AppTextStyles.smallTextStyle,)
              ],)),
              PopupMenuItem(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  value: 1,
                  child: Row(
                    spacing: 12,
                    children: [
                      SvgPicture.asset(AppIcons.icBlockUser),
                      Text("Block user", style: AppTextStyles.smallTextStyle,)
                    ],))
            ];
          })
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            RemoteUserProfileInfoWidget(userID: _userID, userName: _userName, profilePicture: _profilePicture, isFromProfilePage: true,)
          ],
        ),
      )
    );
  }
}