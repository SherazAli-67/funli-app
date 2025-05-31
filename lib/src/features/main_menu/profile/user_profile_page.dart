import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/providers/profile_provider.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
import 'package:funli_app/src/widgets/profile_info_widget.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget{
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {

  @override
  Widget build(BuildContext context) {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    return SizedBox.expand(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<ProfileProvider>(builder: (ctx, provider, _){
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 2,
                        child: SingleChildScrollView(
                          child: Row(
                            spacing: 20,
                            children: [

                              AppBackButton(color: Colors.black,),
                              Text(provider.currentUser != null ? provider
                                  .currentUser!.userName : "User not found",
                                style: AppTextStyles.headingTextStyle3,),

                            ],),
                        )),
                    Expanded(child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(onPressed: () {},
                            icon: SvgPicture.asset(AppIcons.icAnalytics)),
                        IconButton(onPressed: () {},
                            icon: SvgPicture.asset(AppIcons.icSettings)),
                      ],))


                  ],
                );
              }),
              ProfileInfoWidget(userID: userID)
            ],
          ),
        ),
      ),
    );
  }


}