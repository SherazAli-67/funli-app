import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import '../res/app_textstyles.dart';
import '../res/spacing_constants.dart';

class PrimaryBtn extends StatelessWidget {
  const PrimaryBtn({
    super.key,
    required String btnText, required String icon, required VoidCallback onTap, String bgGradient = AppIcons
        .btnBgGradient, bool isPrefix = false, bool isLoading = false, double borderRadius = SpacingConstants
        .btnBorderRadius, Color? iconColor,
    TextStyle textStyle = AppTextStyles.buttonTextStyle
  })
      : _text = btnText,
        _icon = icon,
        _onTap = onTap,
        _isPrefix = isPrefix,
        _isLoading = isLoading,
        _bgGradient = bgGradient,
        _borderRadius = borderRadius,
        _iconColor = iconColor,
  _textStyle = textStyle
  ;
  final String _text;
  final String _icon;
  final VoidCallback _onTap;
  final bool _isPrefix;
  final bool _isLoading;
  final String _bgGradient;
  final double _borderRadius;
  final Color? _iconColor;
  final TextStyle _textStyle;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.btnOuterGradient,
           /* boxShadow: [
              BoxShadow(
                  color: Color(0xffC9BAFF),
                  blurRadius: 17.6,
                  offset: Offset(0, 6)
              )
            ],*/
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        // padding: EdgeInsets.all(2),
        child: Container(
          width: double.infinity,
          height: SpacingConstants.buttonHeight,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_borderRadius),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(_borderRadius),
                child: Image.asset(_bgGradient, fit: BoxFit.cover, width: double.infinity, height: SpacingConstants.buttonHeight,),
              ),
              _isLoading ? LoadingWidget() : Row(
                spacing: _icon.isNotEmpty ? 10 : 0,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(_isPrefix && _icon.isNotEmpty)
                    SvgPicture.asset(_icon, colorFilter: _iconColor != null ? ColorFilter.mode(_iconColor, BlendMode.srcIn) :null,),
                  Text(_text, style: _textStyle.copyWith(color: Colors.white),),
                  if(!_isPrefix && _icon.isNotEmpty)
                    SvgPicture.asset(_icon, colorFilter: _iconColor != null ? ColorFilter.mode(_iconColor, BlendMode.srcIn) :null,)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}