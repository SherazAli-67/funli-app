import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import '../res/app_textstyles.dart';
import '../res/spacing_constants.dart';

class PrimaryBtn extends StatelessWidget {
  const PrimaryBtn({
    super.key,
    required String btnText, required String icon, required VoidCallback onTap,  bool isPrefix = false, bool isLoading = false, double borderRadius = SpacingConstants
        .btnBorderRadius, Color? iconColor,
    TextStyle textStyle = AppTextStyles.buttonTextStyle
  })
      : _text = btnText,
        _icon = icon,
        _onTap = onTap,
        _isPrefix = isPrefix,
        _isLoading = isLoading,
        _borderRadius = borderRadius,
        _iconColor = iconColor,
  _textStyle = textStyle
  ;
  final String _text;
  final String _icon;
  final VoidCallback _onTap;
  final bool _isPrefix;
  final bool _isLoading;
  final double _borderRadius;
  final Color? _iconColor;
  final TextStyle _textStyle;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.colorBlack,
          borderRadius: .circular(_borderRadius),
        ),
        padding: EdgeInsets.all(15),
        child: _isLoading ? LoadingWidget() : Row(
          spacing: _icon.isNotEmpty ? 10 : 0,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(_isPrefix && _icon.isNotEmpty)
              SvgPicture.asset(_icon, colorFilter: _iconColor != null ? ColorFilter.mode(_iconColor, BlendMode.srcIn) :null,),
            Text(_text, style: _textStyle.copyWith(color: Colors.white),),
            // if(!_isPrefix && _icon.isNotEmpty)
            //   SvgPicture.asset(_icon, colorFilter: _iconColor != null ? ColorFilter.mode(_iconColor, BlendMode.srcIn) :null,)
          ],
        ),
      ),
    );
  }
}