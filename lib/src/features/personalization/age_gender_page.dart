import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/providers/personal_info_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/select_gender_widget.dart';
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
      builder: (ctx, provider, _){
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
              child: SelectGenderWidget(title: 'What is your gender?', selectedGender: provider.selectedGender, onSelectGender: (gender)=> provider.setGender(gender)),
            )
          ],
        );
      },
    );
  }


}