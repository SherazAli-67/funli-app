import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:funli_app/src/widgets/primary_gradient_background.dart';

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
                  padding: const EdgeInsets.symmetric(vertical: 47.0, horizontal: 23),
                  child: Column(
                    spacing: 14,
                    children: [
                      Container(
                        width: double.infinity,
                        height: SpacingConstants.buttonHeight,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(SpacingConstants.borderRadius),
                            color: AppColors.colorBlack,
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xffC9BAFF),
                                  blurRadius: 17.6,
                                  offset: Offset(0, 6)
                              )
                            ]
                        ),
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(AppIcons.icMail),
                            Text("Continue with Email", style: AppTextStyles.buttonTextStyle.copyWith(color: Colors.white),)
                          ],
                        ),
                      ),
                      SizedBox(
                        height: SpacingConstants.buttonHeight,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(SpacingConstants.borderRadius),
                                    side: BorderSide(color: AppColors.borderColor)
                                ),
                            ),
                            onPressed: (){}, child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 10,
                          children: [
                            SvgPicture.asset(AppIcons.icGoogle,),
                            Text("Continue with Google", style: AppTextStyles.buttonTextStyle.copyWith(color: AppColors.colorBlack),)
                          ],
                        )),
                      )
                    ],
                  ),
                ),
              ))
        ],
      )
    );
  }
}
