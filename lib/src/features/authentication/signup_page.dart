import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/bloc_cubit/auth_cubit.dart';
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
import 'package:funli_app/src/widgets/terms_of_use_privacy_policy_text_widget.dart';
import 'package:go_router/go_router.dart';
import '../../bloc_cubit/auth_states.dart';
import '../../providers/discover_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/social_sign_in_btn.dart';

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: .symmetric(horizontal: SpacingConstants.screenHorizontalPadding, vertical: 40),
          child: SizedBox(
            height: size.height*0.9,
            child: Column(
              crossAxisAlignment: .start,
              spacing: 28,
              children: [
                Row(
                  crossAxisAlignment: .start,
                  spacing: 15,
                  children: [
                    AppBackButton(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        mainAxisAlignment: .start,
                        spacing: 14,
                        children: [
                          Text("Create an account", style: AppTextStyles.headingTextStyle3,),
                          Text("Let’s get you onboard", style: AppTextStyles.regularTextStyle,)
                        ],
                      ),
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
                        textInputType: .emailAddress,
                        hintText: "iejohndoe@gmail.com",
                        titleText: "Email/Username"),

                    AppTextField(textController: _passwordController,
                      prefixIcon: AppIcons.icPasswordLock,
                      hintText: "**************",
                      titleText: "Password", isPassword: true,),
                    TermsOfUsePrivacyPolicyTextWidget(),

                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    BlocConsumer<AuthCubit, AuthStates>(
                      listener: (ctx, state){
                        if(state is SigningUpFailed){
                          SnackbarMessagesHelper.showSnackBarMessage(context: context, title: "Account Creation Failed", message: state.errorMessage);
                        }else if(state is SignedUp){
                          SnackbarMessagesHelper.showSnackBarMessage(context: context, title: AppConstants.signedUpSuccessTitle, message: AppConstants.signedUpSuccessMessage);
                          //Initializing the Trending moods and Hashtags so that user don't have to wait
                          context.read<DiscoverProvider>();
                          context.pushReplacement(RouterEnum.personalizationView.routeName);
                        }
                      },
                      builder: (ctx, state){
                        return Column(
                          spacing: 16,
                          children: [
                            PrimaryBtn(btnText: "Create Account", icon: AppIcons.icArrowNext, onTap: _onSignupTap, isLoading: state is SigningUp,),
                            Row(
                              spacing: 10,
                              children: [
                                Expanded(child: Container(height: 1, color: AppColors.borderColor,)),
                                Text("Or", style: AppTextStyles.smallTextStyle,),
                                Expanded(child: Container(height: 1, color: AppColors.borderColor,)),
                              ],
                            ),
                            SocialSignInBtn(btnTitle: "Continue with Google", icon: AppIcons.icGoogle),
                            SocialSignInBtn(btnTitle: "Continue with Apple", icon: AppIcons.icApple),

                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 30,),
                    RichText(text: TextSpan(
                        children: [
                          TextSpan(text: "Already have any account? ", style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.greyTextColor, fontFamily: AppConstants.appFontFamily)),
                          TextSpan(
                              recognizer: TapGestureRecognizer()..onTap = ()=> context.pushReplacement(RouterEnum.loginView.routeName),
                              text: "Sign in!", style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.colorBlack, fontFamily: AppConstants.appFontFamily)),

                        ]
                    ))
                  ],
                ),
              ],
            ),
          ),
        ),
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
