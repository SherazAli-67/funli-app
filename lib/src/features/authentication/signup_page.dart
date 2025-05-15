import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/bloc_cubit/auth_cubit.dart';
import 'package:funli_app/src/features/authentication/login_page.dart';
import 'package:funli_app/src/features/personalization/personalization_page.dart';
import 'package:funli_app/src/helpers/snackbar_messages_helper.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:funli_app/src/widgets/app_textfield.dart';
import 'package:funli_app/src/widgets/auth_pages_header_text_widget.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/primary_gradient_background.dart';
import '../../bloc_cubit/auth_states.dart';
import '../../widgets/app_back_button.dart';

class SignupPage extends StatefulWidget {

  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final TextEditingController _nameController = TextEditingController();
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
                padding: EdgeInsets.symmetric(horizontal: SpacingConstants.screenHorizontalPadding, vertical: 40),
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
                            Text("Join the Mood Movement!", style: AppTextStyles.headingTextStyle3,),
                            const SizedBox(height: 14,),
                            Text("Let’s get you onboard 👊’", style: AppTextStyles.bodyTextStyle,)
                          ],
                        ),
                      ],
                    ),
                    Column(
                      spacing: 16,
                      children: [
                        AppTextField(textController: _nameController,
                            prefixIcon: AppIcons.icUser,
                            hintText: "i.e John Doe",
                            titleText: "Full name"),

                        AppTextField(textController: _emailController,
                            prefixIcon: AppIcons.icLoginEmail,
                            textInputType: TextInputType.emailAddress,
                            hintText: "iejohndoe@gmail.com",
                            titleText: "Email/Username"),

                        AppTextField(textController: _passwordController,
                            prefixIcon: AppIcons.icPasswordLock,
                            hintText: "**************",
                            titleText: "Password", isPassword: true,),

                        RichText(text: TextSpan(
                          children: [
                            TextSpan(text: '*By tapping ', style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.black, fontWeight: FontWeight.w400, fontFamily: AppConstants.appFontFamily)),
                            TextSpan(text: '‘Create Account’, ', style: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.purpleColor, fontWeight: FontWeight.w400, fontFamily: AppConstants.appFontFamily)),
                            TextSpan(text: 'you’re cool with our Terms & Privacy. 💯*', style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.black, fontWeight: FontWeight.w400, fontFamily: AppConstants.appFontFamily))
                          ]
                        ))

                      ],
                    ),
                    Column(
                      children: [

                        BlocConsumer<AuthCubit, AuthStates>(
                          listener: (ctx, state){
                            if(state is SigningUpFailed){
                              SnackbarMessagesHelper.showSnackBarMessage(context: context, title: "Account Creation Failed", message: state.errorMessage);
                            }else if(state is SignedUp){
                              SnackbarMessagesHelper.showSnackBarMessage(context: context, title: AppConstants.signedUpSuccessTitle, message: AppConstants.signedUpSuccessMessage);
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> PersonalizationPage()), (val)=> false);
                            }
                          },
                          builder: (ctx, state){
                            return PrimaryBtn(btnText: "Create Account", icon: AppIcons.icArrowNext, onTap: _onSignupTap, isLoading: state is SigningUp,);
                          },
                        ),

                        const SizedBox(height: 30,),
                        RichText(text: TextSpan(
                          children: [
                            TextSpan(text: "Already have any account? ", style: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.colorBlack, fontFamily: AppConstants.appFontFamily)),
                            TextSpan(
                                recognizer: TapGestureRecognizer()..onTap = (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> LoginPage()));
                                },
                                text: "Sign in!", style: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.purpleColor, fontFamily: AppConstants.appFontFamily)),

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

  void _onSignupTap(){
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();

    if(email.isEmpty || password.isEmpty || name.isEmpty){

      if(email.isEmpty){
        //Display Enter email snackbar
      }else if(password.isEmpty){
        //Display Enter password snackbar
      }else if(name.isEmpty){
        //Display Enter name snacbar
      }
      return;
    }
    context.read<AuthCubit>().onSignupWithEmail(email: email, password: password, name: name);
  }
}
