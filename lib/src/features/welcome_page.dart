import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/authentication/login_page.dart';
import 'package:funli_app/src/res/app_colors.dart';
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
      child: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 23),
              child: Column(children: [
                Text("Express Your Mood, Your Way! ", style: AppTextStyles.headingTextStyle3,),
                const SizedBox(height: 14,),
                Text("Discover a world where your mood shapes your feed. 🌈 ", style: AppTextStyles.bodyTextStyle,),
                const SizedBox(height: 46,),
                CarouselSlider(
                    items: [
                      AppIcons.onboarding1, AppIcons.onboarding2, AppIcons.onboarding3
                    ].map((img){
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(img, fit: BoxFit.cover),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: size.height*0.5,
                      aspectRatio: 16/9,
                      viewportFraction: 0.8,
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
                )
              ]),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
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
              ))
        ],
      )
    );
  }

  void _onEmailTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> LoginPage()));
  }
}
