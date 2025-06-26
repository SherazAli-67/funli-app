import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/features/settings/widgets/settings_item_widget.dart';
import 'package:funli_app/src/providers/profile_provider.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';
import 'package:go_router/go_router.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 30,
          children: [
            Consumer<ProfileProvider>(
              builder: (context, provider, _) {
                return provider.currentUser != null ? ListTile(
                  onTap: ()=> context.push(RouterEnum.updateProfileView.routeName),
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
                ) : const SizedBox();
              }
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("App Settings", style: AppTextStyles.subHeadingTextStyle,),
                  SettingsItemWidget(icon: AppIcons.icVisibility, title: 'Dark Mode',  isSwitch: true, onTap: (){
                    Fluttertoast.showToast(msg: "Dark mode development in-progress");
                  },),
                  SettingsItemWidget(icon: AppIcons.icSecurity, title: 'Security & Privacy', onTap: ()=> _onSecurityPrivacyTap(context),),
                  SettingsItemWidget(icon: AppIcons.icVideo, title: 'Content Preferences', onTap: ()=> _onContentPreferencesTap(context),),
                  SettingsItemWidget(icon: AppIcons.icEdit, title: 'Report a Problem', onTap: ()=> _onReportProblemTap(context),),
                  SettingsItemWidget(icon: AppIcons.icHelpCenter, title: 'Help Center', onTap: ()=> _onHelpCenterTap(context),),
                  SettingsItemWidget(icon: AppIcons.icTermsPrivacy, title: 'Terms & Service',onTap: ()=> _onTermsPrivacyTap(context), ),
        
                ],
              ),
            ),
            Center(child: Text("V1.0.1", style: AppTextStyles.bodyTextStyle,),),
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
    return currentYear - dobYear;
  }

  void _onLogoutTap(BuildContext context) async {
    // Clear all cache and logout - reset from everywhere
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    await FirebaseAuth.instance.signOut();
    provider.clear();
    // Use `go` to replace the entire stack and leave ShellRoute
    context.go(RouterEnum.welcomeView.routeName);
  }
  
  void _onSecurityPrivacyTap(BuildContext context){
    context.push(RouterEnum.securityAndPrivacyView.routeName);
  }

  void _onContentPreferencesTap(BuildContext context){
    context.push(RouterEnum.contentPreferenceView.routeName);
  }

  void _onReportProblemTap(BuildContext context){
    context.push(RouterEnum.reportAProblemView.routeName);
  }

  void _onHelpCenterTap(BuildContext context){
    context.push(RouterEnum.helpCenterView.routeName);
  }

  void _onTermsPrivacyTap(BuildContext context){
    context.push(RouterEnum.termsAndPrivacyView.routeName);
  }
}
