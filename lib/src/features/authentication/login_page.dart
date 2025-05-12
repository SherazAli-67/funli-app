import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/bloc_cubit/auth_cubit.dart';
import 'package:funli_app/src/bloc_cubit/auth_states.dart';
import 'package:funli_app/src/features/authentication/forget_password_page.dart';
import 'package:funli_app/src/features/authentication/signup_page.dart';
import 'package:funli_app/src/features/main_menu/main_menu_page.dart';
import 'package:funli_app/src/helpers/snackbar_messages_helper.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
import 'package:funli_app/src/widgets/app_textfield.dart';
import 'package:funli_app/src/widgets/auth_pages_header_text_widget.dart';
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
          AuthPagesHeaderTextWidget(),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(31), topRight: Radius.circular(31))
              ),
              child: SingleChildScrollView(
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
                            Text("Welcome Back! 🎉", style: AppTextStyles.headingTextStyle3,),
                            const SizedBox(height: 14,),
                            Text("Let’s get you watchin’", style: AppTextStyles.bodyTextStyle,)
                          ],
                        ),
                      ],
                    ),

                    Column(
                      spacing: 16,
                      children: [
                        AppTextField(textController: _emailController,
                            prefixIcon: AppIcons.icLoginEmail,
                            hintText: "iejohndoe@gmail.com",
                            textInputType: TextInputType.emailAddress,
                            titleText: "Email/Username"),

                        AppTextField(textController: _passwordController,
                            prefixIcon: AppIcons.icPasswordLock,
                            hintText: "**************",
                            titleText: "Password", isPassword: true,),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> ForgetPasswordPage()));
                          }, child: Text(
                            "Oops! Forgot your password?",
                            style: AppTextStyles.bodyTextStyle.copyWith(
                                color: AppColors.purpleColor),)),
                        )

                      ],
                    ),
                    Column(
                      children: [

                        BlocConsumer<AuthCubit, AuthStates>(
                          listener: (ctx, state){
                            if(state is SigningInFailed){
                              SnackbarMessagesHelper.showErrorSnacbarMessage(context: context, title: "Login Failed", message: state.errorMessage);
                            }else if(state is SignedIn){
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> MainMenuPage()), (val)=> false);
                            }
                          },
                          builder: (ctx, state){
                            return PrimaryBtn(btnText: "Login", icon: AppIcons.icArrowNext, onTap: _onLoginTap, isLoading: state is SigningIn,);
                          },
                        ),
                        const SizedBox(height: 30,),
                        RichText(text: TextSpan(
                          children: [
                            TextSpan(text: "Don’t have any account? ", style: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.colorBlack, fontFamily: AppConstants.appFontFamily)),
                            TextSpan(
                                recognizer: TapGestureRecognizer()..onTap = (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> SignupPage()));
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


  void _onLoginTap() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if(email.isEmpty || password.isEmpty){
      return;
    }
    context.read<AuthCubit>().signInWithEmail(email: email, password: password,);
  }
}
