import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/secondary_gradient_btn.dart';

class SearchPage extends StatelessWidget{
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text("Discover", style: AppTextStyles.headingTextStyle3,),
        centerTitle: false,
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_ios_new_rounded)),
        leadingWidth: 30,
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greyFillColor,
                padding: EdgeInsets.symmetric(horizontal: 15),
                elevation: 0
              ),
              onPressed: (){}, child: Row(
            spacing: 10,
            children: [
              SvgPicture.asset(AppIcons.icFilter),
              Text("Filter", style: AppTextStyles.smallTextStyle,)
            ],
          ))
        ],
      ),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.searchFillColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.transparent)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.transparent)
                ),
                hintText: 'Search users, feels, trends, hashtags',
                hintStyle: AppTextStyles.hintTextStyle,
                prefixIcon: Icon(Icons.search, color: AppColors.greyTextColor,)
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Trending Hashtags", style: AppTextStyles.buttonTextStyle.copyWith(fontWeight: FontWeight.w700),),
                ...List.generate(4, (index){
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(text: TextSpan(
                              children: [
                                TextSpan(text: "#happinessinpak  ", style: AppTextStyles.smallTextStyle.copyWith(fontWeight: FontWeight.w700, fontFamily: AppConstants.appFontFamily, color: Colors.black),),
                                TextSpan(text: "20k feels ", style: AppTextStyles.smallTextStyle.copyWith(fontFamily: AppConstants.appFontFamily, color: AppColors.hashtagCountGreyColor),),
                              ]
                          )),
                        ),
                        SecondaryGradientBtn(btnText: "Following", icon: '', onTap: (){}, buttonHeight: 40,)
                      ],
                    ),
                  );
                })
              ],
            )
          ],
        ),
      )),
    );
  }

}