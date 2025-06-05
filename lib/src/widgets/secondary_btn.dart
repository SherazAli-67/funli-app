import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../res/app_colors.dart';
import '../res/app_textstyles.dart';
import '../res/spacing_constants.dart';

class SecondaryBtn extends StatelessWidget {
  const SecondaryBtn({
    super.key,
    required String btnText, required String icon, required VoidCallback onTap, bool isPrefix = false,
    double borderRadius = SpacingConstants.btnBorderRadius,
    TextStyle textStyle = AppTextStyles.buttonTextStyle,
  }): _text = btnText, _icon = icon, _onTap = onTap, _isPrefix = isPrefix, _borderRadius = borderRadius, _textStyle = textStyle;
  final String _text;
  final String _icon;
  final VoidCallback _onTap;
  final bool _isPrefix;
  final double _borderRadius;
  final TextStyle _textStyle;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SpacingConstants.buttonHeight,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_borderRadius),
                side: BorderSide(color: AppColors.borderColor)
            ),
          ),
          onPressed: _onTap, child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        spacing: _icon.isNotEmpty ? 10 : 0,
        children: [
          if(_isPrefix && _icon.isNotEmpty)
            SvgPicture.asset(_icon),
          Text(_text, style: _textStyle.copyWith(color: AppColors.colorBlack),),
          if(!_isPrefix  && _icon.isNotEmpty)
            SvgPicture.asset(_icon),
        ],
      )),
    );
  }
}