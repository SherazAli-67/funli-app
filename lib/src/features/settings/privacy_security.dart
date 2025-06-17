import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/features/settings/widgets/settings_item_widget.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/settings_service.dart';
import 'package:funli_app/src/widgets/gradient_text_widget.dart';

class PrivacySecurity extends StatelessWidget{
  const PrivacySecurity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.arrow_back_ios_new_rounded,)),
        title: Text("Security & Privacy", style: AppTextStyles.headingTextStyle3,),
        centerTitle: false,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text("Privacy", style: AppTextStyles.tileTitleTextStyle,),
          StreamBuilder(
              stream: SettingsService.isPrivateAccount(FirebaseAuth.instance.currentUser!.uid),
              builder: (ctx, snapshot){
                if(snapshot.hasData){
                  bool isPrivate = snapshot.requireData;
                  return SettingsItemWidget(title: "Private Account",
                    isSwitch: true,
                    switchValue: isPrivate,
                    onSwitchChange: (val) =>
                        SettingsService.setAccountVisibility(visibility: ProfileVisibility.followersOnly),);
                }

                return SettingsItemWidget(title: "Private Account",
                  isSwitch: true,
                  onSwitchChange: (val) =>
                      SettingsService.setAccountVisibility(visibility: ProfileVisibility.followersOnly),);
              },),
          StreamBuilder(
            stream: SettingsService.getSuggestAccountToOthers(),
            builder: (ctx, snapshot){
              if(snapshot.hasData){
                bool isSuggest = snapshot.requireData;
                return SettingsItemWidget(title: "Suggest Account to others", isSwitch: true, switchValue: isSuggest, onSwitchChange: (val)=> SettingsService.setSuggestAccountToOthers(isSuggest: val),);
              }

              return SettingsItemWidget(title: "Suggest Account to others", isSwitch: true, switchValue: false, onSwitchChange: (val)=> SettingsService.setSuggestAccountToOthers(isSuggest: val),);
            },),
          SettingsItemWidget(title: "Who can see your feels", onTap: ()=> _onWhoElseCanSeeYourFeels(context),),
            Text("Security", style: AppTextStyles.tileTitleTextStyle,),
            StreamBuilder(
              stream: SettingsService.getRememberMe(),
              builder: (ctx, snapshot){
                if(snapshot.hasData){
                  bool rememberMe = snapshot.requireData;
                  return SettingsItemWidget(title: "Remember me",
                    isSwitch: true,
                    switchValue: rememberMe,
                    onSwitchChange: (val) =>
                        SettingsService.setRememberMe(rememberMe: val),);
                }

                return SettingsItemWidget(title: "Remember me",
                  switchValue: true,
                  isSwitch: true,
                  onSwitchChange: (val) => SettingsService.setRememberMe(rememberMe: val),);
              },),
        ],),
      )),
    );
  }

  void _onWhoElseCanSeeYourFeels(BuildContext context){
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context, builder: (ctx){
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text("Who can see your feels", style: AppTextStyles.headingTextStyle3,)),
                  IconButton(onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.close), style: IconButton.styleFrom(
                      backgroundColor: AppColors.lightGreyColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))
                  ),)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: StreamBuilder<ProfileVisibility>(
                stream: SettingsService.getProfileVisibility(),
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  final visibility = snapshot.requireData;

                  Widget buildOption(String label, ProfileVisibility type) {
                    final isSelected = visibility == type;
                    final textStyle = AppTextStyles.buttonTextStyle.copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, color: !isSelected ? AppColors.darkGreyColor: null);

                    return TextButton(
                      onPressed: () =>
                          SettingsService.setAccountVisibility( visibility: type),
                      child: isSelected
                          ? GradientTextWidget(
                        gradient: AppGradients.primaryGradient,
                        text: label,
                        textStyle: textStyle,
                      )
                          : Text(label, style: textStyle),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildOption("Everyone", ProfileVisibility.public),
                      buildOption("Followers of Followers", ProfileVisibility.followersOfFollowers),
                      buildOption("Followers only", ProfileVisibility.followersOnly),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      );
    });
  }
}