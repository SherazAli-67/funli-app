import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/providers/personal_info_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:provider/provider.dart';

class AgeGenderPage extends StatefulWidget{
  const AgeGenderPage({super.key});

  @override
  State<AgeGenderPage> createState() => _AgeGenderPageState();
}

class _AgeGenderPageState extends State<AgeGenderPage> {

  final months = List<String>.generate(12, (i) => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][i]);
  final days = List<int>.generate(31, (i) => i + 1);
  final years = List<int>.generate(101, (i) => 1925 + i);



  double itemExtent = 60;

  Widget buildPicker<T>({
    required List<T> items,
    required int selectedIndex,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return SizedBox(
      width: 100,
      height: itemExtent * 3,
      child: Stack(
        children: [
          ListWheelScrollView.useDelegate(
            itemExtent: itemExtent,
            perspective: 0.005,
            physics: FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelectedItemChanged,
            controller: FixedExtentScrollController(initialItem: selectedIndex),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (context, index) {
                final isSelected = index == selectedIndex;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8), // 8 top + 8 bottom = 16 total
                    child: Text(
                      items[index].toString(),
                      style: TextStyle(
                        fontSize: isSelected ? 32 : 24,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? AppColors.colorBlack : AppColors.lightBlackColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Top Divider
          Positioned(
            top: itemExtent,
            left: 10,
            right: 10,
            child: Divider(thickness: 1),
          ),
          // Bottom Divider
          Positioned(
            top: itemExtent * 2,
            left: 10,
            right: 10,
            child: Divider(thickness: 1),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalInfoProvider>(
      builder: (_, provider, _){
        String selectedGender = provider.selectedGender;
        return Column(
          children: [
            Expanded(
                child: Column(
                    children: [
                      Text("How old are you?", style: AppTextStyles.subHeadingTextStyle.copyWith(fontWeight: FontWeight.w400),),
                      Expanded(child:  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildPicker<String>(
                            items: months,
                            selectedIndex: provider.selectedMonth,
                            onSelectedItemChanged: (month){
                              provider.setMonth(month);
                            },
                          ),
                          buildPicker<int>(
                            items: days,
                            selectedIndex: provider.selectedDay,
                            onSelectedItemChanged: (day){
                              provider.setDay(day);
                            },
                          ),
                          buildPicker<int>(
                            items: years,
                            selectedIndex: provider.selectedYear,
                            onSelectedItemChanged: (year){
                              provider.setYear(year);
                            },
                          ),
                        ],
                      ),)
                    ])
            ),
            Expanded(
              child: Column(
                spacing: 16,
                children: [
                  Text("What is your gender?", style: AppTextStyles.subHeadingTextStyle.copyWith(fontWeight: FontWeight.w400),),
                  Expanded(child: Column(
                    spacing: 13,
                    children: [
                      _buildGenderItem(gender: "Male", icon: AppIcons.icMale, selectedGender: selectedGender, provider:   provider),
                      _buildGenderItem(gender: "Female", icon: AppIcons.icFemale, selectedGender: selectedGender, provider:   provider),
                      _buildGenderItem(gender: "Rather not say", icon: AppIcons.icGenderRatherNotToSay, selectedGender: selectedGender, provider:   provider),

                    ],
                  )),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildGenderItem({required String gender, required String icon,  required String selectedGender, required PersonalInfoProvider provider}) {
    bool isSelected = selectedGender == gender;
    Color txtIconColor = isSelected ? Colors.white : AppColors.lightBlackColor;
    return GestureDetector(
      onTap: ()=> provider.setGender(gender),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.borderColor),
          color: !isSelected ? Colors.white : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if(isSelected)
              ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(AppIcons.primaryBgGradient, width: double.infinity, fit: BoxFit.cover, height: 65,)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 21, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      spacing: 11,
                      children: [
                        SvgPicture.asset(icon, colorFilter: ColorFilter.mode(txtIconColor, BlendMode.srcIn),),
                        Text(gender, style: AppTextStyles.bodyTextStyle.copyWith(color: txtIconColor),)
                      ],
                    ),
                  ),
                  if(isSelected)
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.white,
                      child: Center(child: Icon(Icons.done, color: Colors.black, size: 15,),),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    /*return CheckboxListTile(
      tileColor: Colors.white,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: BorderSide(
          color: selectedGender == title ? AppColors.purpleColor : AppColors.borderColor
        )
      ),
      value: selectedGender == title,
      onChanged: (val) {
        if (val!) {
          provider.setGender(title);
        }
      },
      title: Text(title, style: AppTextStyles.bodyTextStyle,),
      secondary: SvgPicture.asset(icon),
      checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99)),
    );*/
  }
}