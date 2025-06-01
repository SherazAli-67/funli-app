import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';

class ProfileSettingsPage extends StatelessWidget{
  const ProfileSettingsPage({super.key, required UserModel currentUser}) : _currentUser = currentUser;
  final UserModel _currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Make Some Changes', style: AppTextStyles.headingTextStyle3,),
        leadingWidth: 30,
        centerTitle: false,
      ),
      body: SafeArea(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 30,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ProfilePictureWidget(profilePicture: _currentUser.profilePicture),
            title: Text(_currentUser.userName, style: AppTextStyles.tileTitleTextStyle,),
            subtitle: Text("${getAgeByDOB(_currentUser.dob!)}, ${_currentUser.gender}"),
            trailing: IconButton(onPressed: (){}, icon: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: AppGradients.primaryGradient,

                ),
                child: Icon(Icons.edit, color: Colors.white,)
            )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("App Settings", style: AppTextStyles.subHeadingTextStyle,),
                SettingsItemWidget(icon: AppIcons.icVisibility, title: 'Dark Mode',  isSwitch: true,),
                SettingsItemWidget(icon: AppIcons.icSecurity, title: 'Security & Privacy',),
                SettingsItemWidget(icon: AppIcons.icVideo, title: 'Content Preferences',),
                SettingsItemWidget(icon: AppIcons.icEdit, title: 'Report a Problem', ),
                SettingsItemWidget(icon: AppIcons.icHelpCenter, title: 'Dark Mode',),
                SettingsItemWidget(icon: AppIcons.icHelpCenter, title: 'Help Center',),
                SettingsItemWidget(icon: AppIcons.icTermsPrivacy, title: 'Terms & Service', ),

              ],
            ),
          )
        ],
      )),
    );
  }

  int getAgeByDOB(DateTime dob){
    int currentYear = DateTime.now().year;
    int dobYear = dob.year;
    debugPrint("DOB year: ${dob.toIso8601String()}");
    return currentYear - dobYear;
  }
}

class SettingsItemWidget extends StatelessWidget {
  const SettingsItemWidget({
    super.key,
    required String title,
    required String icon,
    VoidCallback? onTap,
    bool isSwitch = false,
  }): _icon = icon, _title = title, _onTap = onTap,  _isSwitch = isSwitch;
  final String _icon;
  final String _title;
  final bool _isSwitch;
  final VoidCallback? _onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 5),
      onTap: _onTap,
      leading: SvgPicture.asset(_icon),
      title: Text(_title, style: AppTextStyles.buttonTextStyle,),
      trailing: _isSwitch ?  CupertinoSwitch(
          inactiveTrackColor:  AppColors.switchTrackColor,
          activeTrackColor: AppColors.purpleColor,
          value: true, onChanged: (val){}) : Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.navigate_next_outlined),
          )
    );
  }
}