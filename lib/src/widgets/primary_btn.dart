import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import '../res/app_colors.dart';
import '../res/app_textstyles.dart';
import '../res/spacing_constants.dart';

class PrimaryBtn extends StatelessWidget {
  const PrimaryBtn({
    super.key,
    required String btnText, required String icon, required VoidCallback onTap, bool isPrefix = false, bool isLoading = false
  }): _text = btnText, _icon = icon, _onTap = onTap, _isPrefix = isPrefix, _isLoading = isLoading;
  final String _text;
  final String _icon;
  final VoidCallback _onTap;
  final bool _isPrefix;
  final bool _isLoading;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.btnGradient,
            boxShadow: [
              BoxShadow(
                  color: Color(0xffC9BAFF),
                  blurRadius: 17.6,
                  offset: Offset(0, 6)
              )
            ],
          borderRadius: BorderRadius.circular(SpacingConstants.borderRadius),
        ),
        padding: EdgeInsets.all(2),
        child: Container(
          width: double.infinity,
          height: SpacingConstants.buttonHeight,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingConstants.borderRadius),
              color: AppColors.colorBlack,
              boxShadow: [
                BoxShadow(
                    color: Color(0xffC9BAFF),
                    blurRadius: 17.6,
                    offset: Offset(0, 6)
                )
              ]
          ),
          child: _isLoading ? LoadingWidget() : Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(_isPrefix)
                SvgPicture.asset(_icon),
              Text(_text, style: AppTextStyles.buttonTextStyle.copyWith(color: Colors.white),),
              if(!_isPrefix)
                SvgPicture.asset(_icon),
            ],
          ),
        ),
      ),
    );
  }
}