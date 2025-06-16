import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/bloc_cubit/auth_cubit.dart';
import 'package:funli_app/src/bloc_cubit/auth_states.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
import 'package:funli_app/src/widgets/app_textfield.dart';
import 'package:funli_app/src/widgets/auth_pages_header_text_widget.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/primary_gradient_background.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class ForgetPasswordPage extends StatefulWidget {

  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
                            Text("Forgot Password", style: AppTextStyles.headingTextStyle3,),
                            const SizedBox(height: 14,),
                            Text("Let’s find your user account! 👊", style: AppTextStyles.bodyTextStyle,)
                          ],
                        ),
                      ],
                    ),

                  AppTextField(textController: _emailController,
                    prefixIcon: AppIcons.icLoginEmail,
                    hintText: "ie johndoe@gmail.com",
                    titleText: "Email address",),
                     SizedBox(height: size.height*0.25,),
                    BlocConsumer<AuthCubit, AuthStates>(
                      builder: (_, state){
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 25.0),
                          child: PrimaryBtn(btnText: "Let’s Go!", icon: AppIcons.icArrowNext, onTap: (){

                            String email = _emailController.text.trim();
                            if(email.isNotEmpty){
                              context.read<AuthCubit>().onForgetPassTap(email: email);
                            }
                          }, isLoading: state is SendingForgetPassLink,),
                        );
                      },
                      listener: (_, state){
                        if(state is SentForgetPassLink){
                          showModalBottomSheet(
                              backgroundColor: Colors.white,
                              context: context, builder: (ctx){
                            return _buildEmailResetLinkSent(context);
                          });
                        }
                      },
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

  Widget _buildEmailResetLinkSent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        spacing: 16,
        children: [
          Expanded(
              flex: 2,
              child: Lottie.asset(AppIcons.icSuccessAnim, repeat: false)),
          Text("Password Reset Email Sent", textAlign: TextAlign.center,
            style: AppTextStyles.headingTextStyle3,),
          Text(
            _emailController.text.trim(), style: AppTextStyles.buttonTextStyle,),
          Text(
            AppConstants.resetEmailSentDescription, textAlign: TextAlign.center,
            style: AppTextStyles.smallTextStyle,),
          Expanded(child: const SizedBox()),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: PrimaryBtn(btnText: "Done", icon: '', onTap: () {
              context.pop();
              context.pop();
            }),
          ),

        ],
      ),
    );
  }
}
