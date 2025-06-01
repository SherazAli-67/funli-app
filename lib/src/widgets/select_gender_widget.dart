import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../res/app_colors.dart';
import '../res/app_icons.dart';
import '../res/app_textstyles.dart';

class SelectGenderWidget extends StatelessWidget{
  const SelectGenderWidget(
      {super.key, required String title, required String selectedGender, required Function(String gender) onSelectGender, bool isEdit = false})
      : _title = title,
        _selectedGender = selectedGender,
        _onSelectGender = onSelectGender,
  _isEdit = isEdit
  ;
  final String _title;
  final String _selectedGender;
  final Function(String gender) _onSelectGender;
  final bool _isEdit;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        _isEdit ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTitleWidget(),
            IconButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.containerFillGreyColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                ),
                onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.close))
          ],
        ): _buildTitleWidget(),
        Expanded(child: Column(
          spacing: 13,
          children: [
            _buildGenderItem(gender: "Male", icon: AppIcons.icMale, ),
            _buildGenderItem(gender: "Female", icon: AppIcons.icFemale, ),
            _buildGenderItem(gender: "Rather not say", icon: AppIcons.icGenderRatherNotToSay,),

          ],
        )),
      ],
    );
  }

  Text _buildTitleWidget() => Text(_title, style: AppTextStyles.subHeadingTextStyle.copyWith(fontWeight: FontWeight.w400),);


  Widget _buildGenderItem({required String gender, required String icon,}) {
    bool isSelected = _selectedGender == gender;
    Color txtIconColor = isSelected ? Colors.white : AppColors.lightBlackColor;
    return GestureDetector(
      onTap: ()=> _onSelectGender(gender),
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