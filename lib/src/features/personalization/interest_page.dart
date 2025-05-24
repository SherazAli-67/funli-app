import 'package:flutter/material.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/providers/personal_info_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:provider/provider.dart';


class InterestPage extends StatefulWidget{
  const InterestPage({super.key});

  @override
  State<InterestPage> createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {

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
                      gradient: isSelected ? AppGradients.interestItemGradient : null
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
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
      ],
    );
  }
}