import 'package:flutter/material.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/providers/personal_info_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:provider/provider.dart';

import '../../res/app_icons.dart';

class InterestPage extends StatefulWidget{
  const InterestPage({super.key});

  @override
  State<InterestPage> createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  List<Map<String, dynamic>> interestList = [
    {
      'color' : Colors.black,
      'interest' : 'Music'
    },
    {
      'color' : AppColors.lightPurple,
      'interest' : 'Football'
    },
    {
      'color' : AppColors.tealColor,
      'interest' : 'Poetry'
    },
    {
      'color' : AppColors.greyColor,
      'interest' : 'Fitness'
    },
    {
      'color' : AppColors.greyColor,
      'interest' : 'Motivation'
    },
    {
      'color' : AppColors.pinkColor,
      'interest' : 'Movies'
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Text("So, What interests you?", style: AppTextStyles.subHeadingTextStyle.copyWith(fontWeight: FontWeight.w400),),
        Consumer<PersonalInfoProvider>(
          builder: (ctx, provider, _){
            return Expanded(child: Wrap(
              children: AppData.interestList.map((interest){
                bool isSelected = provider.selectedInterests.contains(interest);
                Color txtIconColor = isSelected ? Colors.white : AppColors.lightBlackColor;
                return GestureDetector(
                  onTap: ()=> provider.addToInterest(interest),
                  child: Container(
                    // height: 45,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SpacingConstants.btnBorderRadius),
                      border: Border.all(color: AppColors.borderColor),
                      color: !isSelected ? Colors.white : null,
                      gradient: isSelected ? AppGradients.primaryGradient : null
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // if(isSelected)
                        //   ClipRRect(
                        //       borderRadius: BorderRadius.circular(9),
                        //       child: Image.asset(AppIcons.primaryBgGradient, fit: BoxFit.cover, height: 45,)),
                        //
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          child: Text(interest, style: AppTextStyles.bodyTextStyle.copyWith(color: txtIconColor),)
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ));
          },),
        /*
        * Color color = interestList[index]['color'];
              String interest = interestList[index]['interest'];

              bool isSelected = provider.selectedInterests.contains(interest);
              return GestureDetector(
                onTap: ()=> provider.addToInterest(interest),
                child: Container(
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(19)
                  ),
                  child: isSelected ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Center(child: Icon(Icons.done, color: AppColors.purpleColor, size: 20,),),
                      ),
                      Text(interest, style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w600, color: Colors.white),)
                    ],
                  ) : Center(child: Text(interest, style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),),),
                ),
              );
        * */
      ],
    );
  }
}