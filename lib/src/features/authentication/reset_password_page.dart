import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/authentication/forget_password_page.dart';
import 'package:funli_app/src/features/authentication/signup_page.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
import 'package:funli_app/src/widgets/app_textfield.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/primary_gradient_background.dart';

import '../../widgets/auth_pages_header_text_widget.dart';

class ResetPasswordPage extends StatefulWidget {

  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {


  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PrimaryGradientBackground(
      child: Column(
        children: [
          AuthPagesHeaderTextWidget(),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(31), topRight: Radius.circular(31))
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: SpacingConstants.screenHorizontalPadding, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 28,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 15,
                      children: [
                        AppBackButton(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Create a Password", style: AppTextStyles.headingTextStyle3,),
                            const SizedBox(height: 14,),
                            SizedBox(
                                width: size.width*0.8,
                                child: Text("Nice! Reset your password and don’t worry if you forgot again.", style: AppTextStyles.bodyTextStyle,))
                          ],
                        ),
                      ],
                    ),

                    Column(
                      spacing: 16,
                      children: [
                        AppTextField(textController: _passwordController,
                          prefixIcon: AppIcons.icPasswordLock,
                          hintText: "**************",
                          titleText: "New Password", isPassword: true,),

                        AppTextField(textController: _confirmPasswordController,
                            prefixIcon: AppIcons.icPasswordLock,
                            hintText: "**************",
                            titleText: "Confirm New Password", isPassword: true,),

                      ],
                    ),
                    const Spacer(),
                    PrimaryBtn(btnText: "Awesome, Let’s Go!", icon: AppIcons.icArrowNext, onTap: (){}),
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


