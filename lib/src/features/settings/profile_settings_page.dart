import 'package:flutter/material.dart';
import 'package:funli_app/src/features/main_menu/profile/edit_profile_page.dart';
import 'package:funli_app/src/features/settings/content_preferences_page.dart';
import 'package:funli_app/src/features/settings/privacy_security.dart';
import 'package:funli_app/src/features/settings/widgets/settings_item_widget.dart';
import 'package:funli_app/src/features/welcome_page.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/providers/profile_provider.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';
import 'package:provider/provider.dart';

class ProfileSettingsPage extends StatelessWidget{
  const ProfileSettingsPage({super.key, });
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
      body: SafeArea(child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 30,
          children: [
            Consumer<ProfileProvider>(
              builder: (context, provider, _) {
                return ListTile(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (_)=> EditProfilePage()));
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: ProfilePictureWidget(profilePicture: provider.currentUser!.profilePicture),
                  title: Text(provider.userName, style: AppTextStyles.tileTitleTextStyle,),
                  subtitle: Text("${getAgeByDOB(provider.currentUser!.dob!)}, ${provider.gender}"),
                  trailing: Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: AppGradients.primaryGradient,

                      ),
                      child: Icon(Icons.edit, color: Colors.white,)
                  ),
                );
              }
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("App Settings", style: AppTextStyles.subHeadingTextStyle,),
                  SettingsItemWidget(icon: AppIcons.icVisibility, title: 'Dark Mode',  isSwitch: true,),
                  SettingsItemWidget(icon: AppIcons.icSecurity, title: 'Security & Privacy', onTap: ()=> _onSecurityPrivacyTap(context),),
                  SettingsItemWidget(icon: AppIcons.icVideo, title: 'Content Preferences', onTap: ()=> _onContentPreferencesTap(context),),
                  SettingsItemWidget(icon: AppIcons.icEdit, title: 'Report a Problem', ),
                  SettingsItemWidget(icon: AppIcons.icHelpCenter, title: 'Dark Mode',),
                  SettingsItemWidget(icon: AppIcons.icHelpCenter, title: 'Help Center',),
                  SettingsItemWidget(icon: AppIcons.icTermsPrivacy, title: 'Terms & Service', ),
        
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SettingsItemWidget(title: "Logout", icon: AppIcons.icLogout, isLogout: true, onTap: ()=> _onLogoutTap(context),),
            )
          ],
        ),
      )),
    );
  }

  int getAgeByDOB(DateTime dob){
    int currentYear = DateTime.now().year;
    int dobYear = dob.year;
    debugPrint("DOB year: ${dob.toIso8601String()}");
    return currentYear - dobYear;
  }
  void _onLogoutTap(BuildContext context){
    //Clear all cache and logout - reset from everywhere
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    provider.clear();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> WelcomePage()), (val)=> false);
  }
  
  void _onSecurityPrivacyTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_)=> PrivacySecurity()));
  }

  void _onContentPreferencesTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_)=> ContentPreferencesPage()));
  }
}