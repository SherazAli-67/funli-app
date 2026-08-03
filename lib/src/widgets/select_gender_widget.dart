import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/res/app_gradients.dart';

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
        Expanded(child: SingleChildScrollView(
          child: Column(
            spacing: 13,
            children: [
              _buildGenderItem(gender: "Male", icon: AppIcons.icMale, ),
              _buildGenderItem(gender: "Female", icon: AppIcons.icFemale, ),
              _buildGenderItem(gender: "Rather not say", icon: AppIcons.icGenderRatherNotToSay,),
          
            ],
          ),
        )),
      ],
    );
  }

  Text _buildTitleWidget() => Text(_title, style: AppTextStyles.subHeadingTextStyle.copyWith(fontWeight: FontWeight.w400),);


  Widget _buildGenderItem({required String gender, required String icon,}) {
    bool isSelected = _selectedGender == gender;
    // Color txtIconColor = isSelected ? Colors.white : AppColors.lightBlackColor;
    /*return GestureDetector(
      onTap: ()=> _onSelectGender(gender),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.borderColor),
          color: !isSelected ? Colors.white : null,
          // gradient: isSelected ? AppGradients.uploadBtnGradient : null
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  spacing: 11,
                  children: [
                    SvgPicture.asset(icon, ),
                    Text(gender, style: AppTextStyles.bodyTextStyle)
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
      ),
    );*/
    Color txtIconColor = isSelected ? Colors.black : AppColors.genderBorderColor;
    return CheckboxListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: BorderSide(
          color: isSelected ? AppColors.primaryColor : AppColors.genderBorderColor
        )
      ),
      value: isSelected,
      onChanged: (val) {
        if (val!) {
          _onSelectGender(gender);
        }
      },
      title: Text(gender, style: AppTextStyles.regularTextStyle.copyWith(color: txtIconColor),),
      secondary: SvgPicture.asset(icon, colorFilter: ColorFilter.mode(txtIconColor, BlendMode.srcIn),),
      checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),side: BorderSide(color: txtIconColor)
      ),
    );
  }
}