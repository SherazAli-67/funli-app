import 'package:flutter/material.dart';
import 'package:funli_app/src/providers/personal_info_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:provider/provider.dart';

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
        Text("So, What interests you?", style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400),),
        Consumer<PersonalInfoProvider>(
          builder: (ctx, provider, _){
            return Expanded(child: GridView.builder(
                itemCount: interestList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20
                ), itemBuilder: (ctx, index) {
              Color color = interestList[index]['color'];
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
            }));
          },),
      ],
    );
  }
}