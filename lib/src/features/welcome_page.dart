import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/features/authentication/login_page.dart';
import 'package:funli_app/src/models/onboarding_model.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
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
      child:  Padding(
        // padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 23),
        padding: EdgeInsets.zero,
        child: Column(children: [
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
                        Text(item.title, style: AppTextStyles.headingTextStyle3,),
                        Text(item.subTitle, style: AppTextStyles.bodyTextStyle,),
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
                    viewportFraction: 0.88,
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
            color: Colors.white,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 47.0, horizontal: SpacingConstants.screenHorizontalPadding),
              child: Column(
                spacing: 14,
                children: [
                  PrimaryBtn(btnText: "Continue with Email",icon: AppIcons.icMail, onTap: ()=> _onEmailTap(context), isPrefix: true,),
                  SecondaryBtn(btnText: "Continue with Google", icon: AppIcons.icGoogle, onTap: (){}, isPrefix: true,)
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }

  void _onEmailTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> LoginPage()));
  }
}
