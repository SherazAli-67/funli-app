import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/bloc_cubit/auth_cubit.dart';
import 'package:funli_app/src/bloc_cubit/auth_states.dart';
import 'package:funli_app/src/helpers/snackbar_messages_helper.dart';
import 'package:funli_app/src/providers/discover_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
import 'package:funli_app/src/widgets/app_textfield.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/social_sign_in_btn.dart';
import 'package:go_router/go_router.dart';

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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: .symmetric(horizontal: SpacingConstants.screenHorizontalPadding, vertical: 30),
          child: SizedBox(
            height: size.height*0.85,
            child: Column(
              crossAxisAlignment: .start,
              spacing: 28,
              children: [
                Row(
                  crossAxisAlignment: .start,
                  spacing: 15,
                  children: [

                    AppBackButton(),
                    Column(
                      crossAxisAlignment: .start,
                      mainAxisAlignment: .start,
                      spacing: 14,
                      children: [
                        Text("Welcome Back!", style: AppTextStyles.headingTextStyle3,),
                        Text("Let’s get you watchin’", style: AppTextStyles.regularTextStyle,)
                      ],
                    ),
                  ],
                ),

                Column(
                  spacing: 16,
                  children: [
                    AppTextField(textController: _emailController,
                        prefixIcon: AppIcons.icLoginEmail,
                        hintText: "e.g. john@email.com",
                        textInputType: .emailAddress,
                        titleText: "Email"),

                    AppTextField(textController: _passwordController,
                      prefixIcon: AppIcons.icPasswordLock,
                      hintText: "**************",
                      titleText: "Password", isPassword: true,),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(onPressed: () => context.push(RouterEnum.forgetPassView.routeName),
                          child: Text("Forgot Password?", style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.colorBlack, fontWeight: .bold, decoration: .underline, decorationColor: AppColors.colorBlack),)),)

                  ],
                ),
                const Spacer(),
                Column(
                  children: [

                    BlocConsumer<AuthCubit, AuthStates>(
                      listener: (ctx, state){
                        if(state is SigningInFailed){
                          SnackbarMessagesHelper.showSnackBarMessage(context: context, title: "Login Failed", message: state.errorMessage, isError: true);
                        }else if(state is SignedIn){
                          SnackbarMessagesHelper.showSnackBarMessage(context: context, title: AppConstants.signedInSuccessTitle, message: AppConstants.signedInSuccessMessage);

                          //Initializing the Trending moods and Hashtags so that user don't have to wait
                          context.read<DiscoverProvider>();
                          while(context.canPop()){
                            context.pop();
                          }
                          context.push(RouterEnum.homeView.routeName);
                          // context.push(RouterEnum.personalizationView.routeName);
                        }
                      },
                      builder: (ctx, state){
                        return Column(
                          spacing: 16,
                          children: [
                            PrimaryBtn(btnText: "Login", icon: AppIcons.icArrowNext, onTap: _onLoginTap, isLoading: state is SigningIn,),
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
                          TextSpan(text: "Don’t have any account? ", style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.greyTextColor, fontFamily: AppConstants.appFontFamily, fontWeight: FontWeight.w400)),
                          TextSpan(
                              recognizer: TapGestureRecognizer()..onTap = (){
                                context.pushReplacement(RouterEnum.signupView.routeName);
                              },
                              text: "Create one!", style: AppTextStyles.regularTextStyle.copyWith(color: AppColors.colorBlack, fontFamily: AppConstants.appFontFamily, fontWeight: FontWeight.w400)),

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


  void _onLoginTap() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if(email.isEmpty || password.isEmpty){
      return;
    }
    context.read<AuthCubit>().signInWithEmail(email: email, password: password,);
  }
}
