import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/features/settings/widgets/settings_item_widget.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/services/auth_service.dart';
import 'package:funli_app/src/services/settings_service.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import '../../app_data.dart';
import '../../res/app_colors.dart';
import '../../res/app_textstyles.dart';
import '../../res/spacing_constants.dart';

class ContentPreferencesPage extends StatefulWidget{
  const ContentPreferencesPage({super.key});

  @override
  State<ContentPreferencesPage> createState() => _ContentPreferencesPageState();
}

class _ContentPreferencesPageState extends State<ContentPreferencesPage> {

  final List<String> _selectedPreferences = [];
  bool _loadingPreferences = false;
  bool _onSavingChanges = false;
  @override
  void initState() {
    _initPreferences();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.arrow_back_ios_new_rounded,)),
      title: Text("Content Preferences", style: AppTextStyles.headingTextStyle3,),
      centerTitle: false,
      scrolledUnderElevation: 0,
      elevation: 0,
    ),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
        child: Column(
          spacing: 24,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Control Content", style: AppTextStyles.tileTitleTextStyle,),
                StreamBuilder(stream: SettingsService.getShowAdultContent(), builder: (ctx, snapshot){
                  if(snapshot.hasData){
                    bool showAdultContent = snapshot.requireData;

                    return SettingsItemWidget(title: "18+ Content", isSwitch: true, switchValue: showAdultContent, onSwitchChange: (val)=> SettingsService.setShowAdultContent(showAdultContent: val),);
                  }

                  return SizedBox();
                }),
              ],
            ),

            if(!_loadingPreferences)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Text("Preferences", style: AppTextStyles.tileTitleTextStyle,),

                    Expanded(child: Wrap(
                      children: AppData.interestList.map((interest){
                        bool isSelected = _selectedPreferences.contains(interest);
                        Color txtIconColor = isSelected ? Colors.white : AppColors.lightBlackColor;
                        return GestureDetector(
                          onTap: (){
                            if(isSelected){
                              _selectedPreferences.remove(interest);
                            }else{
                              _selectedPreferences.add(interest);
                            }
                            setState(() {});
                          },
                          child: Container(
                            // height: 45,
                            margin: EdgeInsets.only(bottom: 10, right: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(SpacingConstants.btnBorderRadius),
                                border: Border.all(color: AppColors.borderColor),
                                color: isSelected ? AppColors.colorBlack : Colors.white,
                                // gradient: isSelected ? AppGradients.interestItemGradient : null
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    child: Text(interest, style: AppTextStyles.regularTextStyle.copyWith(color: txtIconColor),)
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ))
                  ],
                ),
              ),

            PrimaryBtn(btnText: "Save Changes", icon: '', onTap: _onSaveChangesTap, isLoading: _onSavingChanges,)
          ],
        ),
      )),
    );
  }

  void _initPreferences() async{
    setState(()=> _loadingPreferences = true);
    String userID = FirebaseAuth.instance.currentUser!.uid;
    UserModel? user = await UserService.getUserByID(userID: userID);
    if(user != null){
      _selectedPreferences.addAll(user.interests);
    }
    _loadingPreferences = false;
    setState(() {});
  }

  void _onSaveChangesTap()async{
    setState(()=>  _onSavingChanges = true);
    //interests
    await AuthService.instance.updateUserInfo(updatedMap: {
      'interests' : _selectedPreferences
    });

    setState(()=>  _onSavingChanges = false);
    Navigator.of(context).pop();
  }
}