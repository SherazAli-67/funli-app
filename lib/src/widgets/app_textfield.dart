import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required TextEditingController textController,
    required String prefixIcon,
    required String hintText,
    required String titleText,
    this.isPassword = false,
    this.isReadOnly = false,
    TextInputType textInputType = TextInputType.text,
    TextStyle hintTextStyle = AppTextStyles.hintTextStyle,
    int maxLines = 1,
  })
      : _textController = textController,
        _prefixIcon = prefixIcon,
        _hintText = hintText,
        _titleText = titleText,
        _textInputType = textInputType,
        _hintTextStyle = hintTextStyle,
        _maxLines = maxLines;

  final TextEditingController _textController;
  final String _prefixIcon;
  final String _hintText;
  final String _titleText;
  final bool isPassword;
  final bool isReadOnly;
  final TextInputType _textInputType;
  final TextStyle _hintTextStyle;
  final int _maxLines;
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool hidePassword = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(widget._titleText.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget._titleText, style: AppTextStyles.bodyTextStyle,),
              const SizedBox(height: 5,),
            ],
          ),
        SizedBox(
          height:  widget._maxLines > 1 ? null : 48,
          child: TextField(
            controller: widget._textController,
            style: AppTextStyles.bodyTextStyle,
            keyboardType: widget._textInputType,
            readOnly: widget.isReadOnly,
            obscureText: widget.isPassword && hidePassword,
            cursorColor: Colors.grey,
            maxLines: widget._maxLines,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderColor)
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.colorBlack)
              ),
              hintText: widget._hintText,
              hintStyle: widget._hintTextStyle,
              prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
              prefixIcon: widget._prefixIcon.isNotEmpty ? SvgPicture.asset(widget._prefixIcon) : null,
              suffixIcon: widget.isPassword ? IconButton(onPressed: ()=> setState(() => hidePassword = !hidePassword), icon: hidePassword ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off)) : null,

            ),
          ),
        )
      ],
    );
  }
}