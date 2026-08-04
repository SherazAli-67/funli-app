import 'package:flutter/material.dart';
import 'package:funli_app/src/models/filter_model.dart';
import 'package:funli_app/src/widgets/sheet_close_icon_widget.dart';
import '../../../res/app_icons.dart';
import '../../../res/app_textstyles.dart';
import '../../../widgets/primary_btn.dart';
import '../../../widgets/secondary_btn.dart';
import '../../../widgets/secondary_gradient_btn.dart';

class FilterBottomSheet extends StatefulWidget{
  const FilterBottomSheet({super.key, required this.currentFilter});
  final ReelFilter currentFilter;
  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();

  static String _capitalize(String value) => value[0].toUpperCase() + value.substring(1);

  static String _popularityLabel(Popularity pop) {
    switch (pop) {
      case Popularity.topFeels:
        return "Top Feels";
      case Popularity.newestFeels:
        return "Newest Feels";
      case Popularity.mostViewed:
        return "Most Viewed";
    }
  }
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final TextEditingController locController = TextEditingController();
  final TextEditingController langController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Mood? selectedMood = widget.currentFilter.selectedMood;
    Popularity? selectedPopularity = widget.currentFilter.selectedPopularity;

    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.only(left: 20,right: 20, top: 20, bottom: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Filters",
                  style: AppTextStyles.headingTextStyle3,),
                SheetCloseIconWidget()
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text("Mood",
                  style: AppTextStyles.regularTextStyle.copyWith(
                      fontWeight: FontWeight.w400),),
                Wrap(
                  spacing: 10,
                  children: Mood.values.map((mood) {
                    bool isSelected = selectedMood == mood;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: isSelected ? SizedBox(
                        width: 100,
                        height: 38,
                        child: PrimaryBtn(
                            btnText: mood.name,
                            icon: '',
                            onTap: () {
                              setState(() => selectedMood = mood);
                            }),
                      ) : SecondaryGradientBtn(
                        btnText: FilterBottomSheet._capitalize(mood.name), icon: '', onTap: () {
                        setState(() => selectedMood = mood);
                      },
                        buttonHeight: 38,
                      ),
                    );

                  }).toList(),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text("Popularity",
                  style: AppTextStyles.regularTextStyle.copyWith(
                      fontWeight: FontWeight.w400),),
                Wrap(
                  spacing: 10,
                  children: Popularity.values.map((popularity) {
                    bool isSelected = selectedPopularity == popularity;
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0),
                      child: isSelected ? SizedBox(
                        width: 150,
                        height: 38,
                        child: PrimaryBtn(
                          btnText: FilterBottomSheet._popularityLabel(popularity), icon: '', onTap: ()=> setState(() => selectedPopularity = popularity),),
                      ) : SecondaryGradientBtn(
                        btnText: FilterBottomSheet._popularityLabel(popularity), icon: '', onTap: ()=> setState(() => selectedPopularity = popularity), buttonHeight: 38,),
                    );
                  }).toList(),
                ),
              ],
            ),
            /*AppTextField(
                textController: locController,
                prefixIcon: AppIcons.icLocation,
                hintText: 'Abu Dahbi, UAE',
                titleText: 'Location'),
            AppTextField(
                textController: langController,
                prefixIcon: AppIcons.icLanguage,
                hintText: 'Urdu',
                titleText: 'Language'),*/

            Row(
              spacing: 20,
              children: [
                Expanded(child: SecondaryBtn(
                    btnText: "Cancel", icon: '', onTap: ()=> Navigator.of(context).pop())),
                Expanded(child: PrimaryBtn(btnText: "Apply",
                  icon: '',
                  onTap: () {
                    Navigator.pop(context, ReelFilter(
                        selectedMood: selectedMood,
                        selectedPopularity: selectedPopularity,
                        ));
                  },)),

              ],
            )
          ],
        ),
      );
    });
  }
}