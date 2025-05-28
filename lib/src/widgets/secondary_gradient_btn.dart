import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/widgets/gradient_text_widget.dart';
import '../res/app_colors.dart';
import '../res/app_textstyles.dart';
import '../res/spacing_constants.dart';

class SecondaryGradientBtn extends StatelessWidget {
  const SecondaryGradientBtn({
    super.key,
    required String btnText, required String icon, required VoidCallback onTap, bool isPrefix = false
  }): _text = btnText, _icon = icon, _onTap = onTap, _isPrefix = isPrefix;
  final String _text;
  final String _icon;
  final VoidCallback _onTap;
  final bool _isPrefix;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SpacingConstants.buttonHeight,
      child: UnicornOutlineButton(
        strokeWidth: 2,
        radius: 24,
        gradient: AppGradients.primaryGradient,
        onPressed: _onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            if(_isPrefix)
              SvgPicture.asset(_icon),
            GradientTextWidget(gradient: AppGradients.primaryGradient, text: _text,),
            if(!_isPrefix)
              SvgPicture.asset(_icon),
          ],
        ),
      ),

      /*ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SpacingConstants.btnBorderRadius),
                side: BorderSide(color: AppColors.borderColor)
            ),
          ),
          onPressed: _onTap, child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          if(_isPrefix)
            SvgPicture.asset(_icon),
          Text(_text, style: AppTextStyles.buttonTextStyle.copyWith(color: AppColors.colorBlack),),
          if(!_isPrefix)
            SvgPicture.asset(_icon),
        ],
      )),*/
    );
  }
}

class UnicornOutlineButton extends StatelessWidget {
  final _GradientPainter _painter;
  final Widget _child;
  final VoidCallback _callback;
  final double _radius;

  UnicornOutlineButton({super.key, 
    required double strokeWidth,
    required double radius,
    required Gradient gradient,
    required Widget child,
    required VoidCallback onPressed,
  })  : _painter = _GradientPainter(strokeWidth: strokeWidth, radius: radius, gradient: gradient),
        _child = child,
        _callback = onPressed,
        _radius = radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _painter,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _callback,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: _callback,
          child: Container(
            constraints: BoxConstraints(minWidth: 88, minHeight: 48),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientPainter extends CustomPainter {
  final Paint _paint = Paint();
  final double _radius;
  final double _strokeWidth;
  final Gradient _gradient;

  _GradientPainter({required double strokeWidth, required double radius, required Gradient gradient})
      : _strokeWidth = strokeWidth,
        _radius = radius,
        _gradient = gradient;

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    Rect outerRect = Offset.zero & size;
    var outerRRect = RRect.fromRectAndRadius(outerRect, Radius.circular(_radius));

    // create inner rectangle smaller by strokeWidth
    Rect innerRect = Rect.fromLTWH(_strokeWidth, _strokeWidth, size.width - _strokeWidth * 2, size.height - _strokeWidth * 2);
    var innerRRect = RRect.fromRectAndRadius(innerRect, Radius.circular(_radius - _strokeWidth));

    // apply gradient shader
    _paint.shader = _gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    Path path1 = Path()..addRRect(outerRRect);
    Path path2 = Path()..addRRect(innerRRect);
    var path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}