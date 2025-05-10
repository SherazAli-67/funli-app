import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:funli_app/src/widgets/app_textfield.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/primary_gradient_background.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return PrimaryGradientBackground(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 65,
              left: SpacingConstants.screenHorizontalPadding,
              right: SpacingConstants.screenHorizontalPadding,
            ),
            child: Column(children: [
              SvgPicture.asset(AppIcons.icFunliHeaderLogo),
              Text("Capture your mood and share your vibe.", style: AppTextStyles.buttonTextStyle,),
              const SizedBox(height: 60,),
            ]),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(31), topRight: Radius.circular(31))
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: SpacingConstants.screenHorizontalPadding, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 28,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(AppIcons.icArrowBack),
                        const SizedBox(height: 6,),
                        Text("Welcome Back! 🎉", style: AppTextStyles.headingTextStyle3,),
                        const SizedBox(height: 14,),
                        Text("Let’s get you watchin’", style: AppTextStyles.bodyTextStyle,)
                      ],
                    ),
                    Column(
                      spacing: 16,
                      children: [
                        AppTextField(textController: _emailController,
                            prefixIcon: AppIcons.icLoginEmail,
                            hintText: "iejohndoe@gmail.com",
                            titleText: "Email/Username"),

                        AppTextField(textController: _passwordController,
                            prefixIcon: AppIcons.icPasswordLock,
                            hintText: "**************",
                            titleText: "Password", isPassword: true,),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(onPressed: () {}, child: Text(
                            "Oops! Forgot your password?",
                            style: AppTextStyles.bodyTextStyle.copyWith(
                                color: AppColors.purpleColor),)),
                        )

                      ],
                    ),
                    Column(
                      children: [

                        PrimaryBtn(btnText: "Login", icon: AppIcons.icArrowNext, onTap: (){}),
                        const SizedBox(height: 30,),
                        RichText(text: TextSpan(
                          children: [
                            TextSpan(text: "Don’t have any account? ", style: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.colorBlack, fontFamily: AppConstants.appFontFamily)),
                            TextSpan(
                                recognizer: TapGestureRecognizer()..onTap = (){
                                  debugPrint("ON tap");
                                },
                                text: "Create one!", style: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.purpleColor, fontFamily: AppConstants.appFontFamily)),

                          ]
                        ))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
