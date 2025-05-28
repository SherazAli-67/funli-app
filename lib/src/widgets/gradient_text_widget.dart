import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/res/app_textstyles.dart';

class GradientTextWidget extends StatelessWidget{
  const GradientTextWidget(
      {super.key, required LinearGradient gradient, required String text, TextStyle textStyle = AppTextStyles
          .buttonTextStyle,})
      : _linearGradient = gradient,
        _text = text,
        _textStyle = textStyle;

  final LinearGradient _linearGradient;
  final String _text;
  final TextStyle _textStyle;
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return _linearGradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      child: Text(
        _text,
        style: _textStyle,
      ),
    );

      /*TextStyle(
          fontSize: 60.0,
          fontWeight: FontWeight.bold,
          foreground: Paint()..shader = linearGradient),*/
    // );
  }

}