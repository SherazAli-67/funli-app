import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/bloc_cubit/auth_cubit.dart';
import 'package:funli_app/src/bloc_cubit/auth_states.dart';
import 'package:funli_app/src/features/authentication/login_page.dart';
import 'package:funli_app/src/features/main_menu/main_menu_page.dart';
import 'package:funli_app/src/features/personalization/personalization_page.dart';
import 'package:funli_app/src/helpers/snackbar_messages_helper.dart';
import 'package:funli_app/src/models/onboarding_model.dart';
import 'package:funli_app/src/providers/personal_info_provider.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/primary_gradient_background.dart';
import 'package:funli_app/src/widgets/secondary_btn.dart';
import '../widgets/primary_btn.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  //
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PrimaryGradientBackground(
      child: Stack(
        children: [
          Column(children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 65.0, bottom: 20),
                child: CarouselSlider(
                    items: [
                      OnboardingModel(image: AppIcons.onboarding1, title: "Express Your Mood, Your Way! ", subTitle: "Discover a world where your mood shapes your feed. 🌈 "),
                      OnboardingModel(image: AppIcons.onboarding1, title: "Your Mood, Your Feed!", subTitle: "Watch content that truly resonates with how you feel. ❤️"),
                      OnboardingModel(image: AppIcons.onboarding1, title: "Share Your Feels! ", subTitle: "Let your emotions take center stage! 🎬 "),

                    ].map((item){
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 14,
                        children: [
                          Text(item.title, style: AppTextStyles.headingTextStyle3.copyWith(color: Colors.white),),
                          Text(item.subTitle, style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white),),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(item.image, fit: BoxFit.cover,),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: size.height*0.75,
                      aspectRatio: 16/9,
                      viewportFraction: 0.85,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.2,
                      scrollDirection: Axis.horizontal,

                    )
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 47.0, horizontal: SpacingConstants.screenHorizontalPadding),
                child: Column(
                  spacing: 14,
                  children: [
                    PrimaryBtn(btnText: "Continue with Email",icon: AppIcons.icMail, onTap: ()=> _onEmailTap(context), isPrefix: true,),
                    Row(
                      spacing: 20,
                      children: [
                        Expanded(child: SecondaryBtn(btnText: "Google", icon: AppIcons.icGoogle, onTap: ()=> _onSignInWithGoogleTap(context), isPrefix: true,borderRadius: 16,),),
                        Expanded(child: SecondaryBtn(btnText: "Apple", icon: AppIcons.icApple, onTap: (){}, isPrefix: true, borderRadius: 16,))

                      ],
                    )
                  ],
                ),
              ),
            )
          ]),
          BlocConsumer<AuthCubit, AuthStates>(builder: (_, state){
            // debugPrint("State: ${state}");
            if(state is SigningInGoogle){
              return Container(
                  width: size.width,
                  height: size.height,
                  color: Colors.black54,
                  child: LoadingWidget()
              );
            }
            
            return SizedBox();
          }, listener: (_, state){
            if(state is SigningInFailed){
              SnackbarMessagesHelper.showSnackBarMessage(context: context, title: "Sign in with Google Failed", message: state.errorMessage, isError: true);
            }else if(state is SignedInGoogle){
              SnackbarMessagesHelper.showSnackBarMessage(context: context, title: AppConstants.signedInSuccessTitle, message: AppConstants.signedInSuccessMessage);
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_)=> MainMenuPage()), (val)=> false);
            }else if(state is SignedUpGoogle){
              context.read<PersonalInfoProvider>().setUserName(state.user.user!.displayName ?? '');
              SnackbarMessagesHelper.showSnackBarMessage(context: context, title: AppConstants.signedUpSuccessTitle, message: AppConstants.signedUpSuccessMessage);
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_)=> PersonalizationPage()), (val)=> false);
            }
          })
        ],
      )
    );
  }

  void _onEmailTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> LoginPage()));
  }

  void _onSignInWithGoogleTap(BuildContext context){
    context.read<AuthCubit>().onGoogleSignInTap();
  }
}
