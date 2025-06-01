
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/helpers/formatting_helpers.dart';
import 'package:funli_app/src/providers/profile_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/widgets/app_textfield.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/primary_gradient_btn.dart';
import 'package:funli_app/src/widgets/select_gender_widget.dart';
import 'package:provider/provider.dart';

import '../../../res/app_gradients.dart';
import '../../../res/app_textstyles.dart';
import '../../personalization/age_gender_page.dart';

class EditProfilePage extends StatefulWidget{
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final TextEditingController _bioTextEditingController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    _initUser();
    super.initState();
  }

  @override
  void dispose() {
    _bioTextEditingController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text('Update Profile', style: AppTextStyles.headingTextStyle3,),
      leadingWidth: 30,
      centerTitle: false,
    ),
      body: SafeArea(child: Consumer<ProfileProvider>(builder: (ctx, provider, _){
       return provider.isProfileLoading ? LoadingWidget(color: AppColors.purpleColor) :
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30),
          child: SizedBox(
            height: size.height*0.8,
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: CachedNetworkImageProvider(provider.currentUser!.profilePicture ?? AppIcons.icDummyImgUrl),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(onPressed: (){}, icon:  Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: AppGradients.primaryGradient,

                            ),
                            child: Icon(Icons.edit, color: Colors.white,)
                        ),),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30,),
                Column(
                  spacing: 12,
                  children: [
                    AppTextField(textController: _nameController, prefixIcon: AppIcons.icUser, hintText: 'John Doe', titleText: 'Full name'),
                    AppTextField(textController: _emailController, prefixIcon: AppIcons.icLoginEmail, hintText: 'email address', titleText: 'Email address', textInputType: TextInputType.emailAddress,),
                    AppTextField(textController: _genderController,
                      prefixIcon: _getGenderIcon(provider.currentUser!.gender),
                      hintText: 'Gender',
                      titleText: 'Gender',
                      isReadOnly: true,
                      suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                      onTap: (){
                      _onGenderTap(selectedGender: provider.currentUser!.gender ?? 'Male', onSelectGender: (gender){});
                      },
                    ),
                    AppTextField(textController: _dobController, prefixIcon: AppIcons.icCalendar, hintText: 'Age', titleText: 'Age', isReadOnly: true, suffixIcon: Icon(Icons.keyboard_arrow_down_rounded)),
                  ],
                ),
                const Spacer(),
                PrimaryGradientBtn(btnText: "Save Changes", icon: AppIcons.icArrowNext, onTap: (){}, borderRadius: 16,)

              ],
            ),
          ),
        );
      })),
    );
  }

  void _initUser() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      final provider = Provider.of<ProfileProvider>(context,listen: false);
      if(provider.currentUser != null){
        _bioTextEditingController.text = provider.currentUser!.bio ?? '';
        _nameController.text = provider.currentUser!.userName;
        _emailController.text = provider.currentUser!.email;
        _genderController.text = provider.currentUser!.gender ?? 'Male';
        _dobController.text = FormatingHelpers.getFormattedDOBWithYearsOld(provider.currentUser!.dob!);
      }else{
        provider.initUserProfile();
      }
    });
  }

  String _getGenderIcon(String? gender) {
    switch(gender){
      case null:
        return AppIcons.icMale;

      case 'Male':
        return AppIcons.icMale;

      case 'Female':
        return AppIcons.icMale;

      case 'Rather not say':
        return AppIcons.icGenderRatherNotToSay;

      default:
        return AppIcons.icMale;
    }
  }


  void _onGenderTap({required String selectedGender, required Function(String) onSelectGender}){
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context, builder: (ctx){
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 20),
        child: SelectGenderWidget(title: 'Edit your gender', selectedGender: selectedGender, onSelectGender: onSelectGender, isEdit: true,),
      );
    });
  }
}