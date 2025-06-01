import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/providers/personal_info_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/select_dob_widget.dart';
import 'package:funli_app/src/widgets/select_gender_widget.dart';
import 'package:provider/provider.dart';

class AgeGenderPage extends StatefulWidget{
  const AgeGenderPage({super.key});

  @override
  State<AgeGenderPage> createState() => _AgeGenderPageState();
}

class _AgeGenderPageState extends State<AgeGenderPage> {



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
                child: SelectDOBWidget(
                  selectedMonth: provider.selectedMonth,
                  onMonthChange: (month)=> provider.setMonth(month),
                  selectedDay:  provider.selectedDay,
                  onDayChange: (day)=> provider.setDay(day),
                  selectedYear: provider.selectedYear,
                  onYearChange: (year)=> provider.setYear(year),
                )
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