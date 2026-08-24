import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_textstyles.dart';

import '../constants/number_const.dart';
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required TextEditingController textController,
    required String hintText,
    required String titleText,
    this.isPassword = false,
    this.isReadOnly = false,
    TextInputType textInputType = TextInputType.text,
    TextStyle hintTextStyle = AppTextStyles.hintTextStyle,
    VoidCallback? onTap,
    InputBorder? enabledBorder,
    InputBorder? focusedBorder,
    int maxLines = 1,
    TextCapitalization? textCapitalization,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    AutovalidateMode? autoValidateMode,
    bool isDense = false,
    String? prefixIcon,
    String? suffixIcon,
    double borderRadius = NumberConst.textFieldBorderRadius,
    Color borderColor = AppColors.borderColor,
    Color focusedBorderColor = AppColors.colorBlack,
    Color errorBorderColor = AppColors.redColor
  })
      : _textController = textController,
        _hintText = hintText,
        _titleText = titleText,
        _textInputType = textInputType,
        _hintTextStyle = hintTextStyle,
        _maxLines = maxLines,
        _onTap = onTap,
  _enabledBorder = enabledBorder,
  _focusedBorder = focusedBorder,
  _textCapitalization = .sentences,
  _validator = validator,
  _inputFormatters = inputFormatters,
  _autoValidateMode = autoValidateMode,
  _isDense = isDense,
  _prefixIcon = prefixIcon,
  _suffixIcon = suffixIcon,
  _borderColor = borderColor,
  _borderRadius = borderRadius,
  _focusedBorderColor = focusedBorderColor,
  _errorBorderColor = errorBorderColor
  ;

  final TextEditingController _textController;
  final String _hintText;
  final String _titleText;
  final bool isPassword;
  final bool isReadOnly;
  final TextInputType _textInputType;
  final TextStyle _hintTextStyle;
  final int _maxLines;
  final VoidCallback? _onTap;
  final InputBorder? _enabledBorder;
  final InputBorder? _focusedBorder;
  final TextCapitalization _textCapitalization;
  final String? Function(String?)? _validator;
  final List<TextInputFormatter>? _inputFormatters;
  final AutovalidateMode? _autoValidateMode;
  final bool _isDense;
  final String? _prefixIcon;
  final String? _suffixIcon;
  final double _borderRadius;
  final Color _borderColor;
  final Color _focusedBorderColor;
  final Color _errorBorderColor;


  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool hidePassword = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: .start,
      children: [
          Text(widget._titleText, style: AppTextStyles.smallTextStyle),
        TextFormField(
          // focusNode: _focusNode,
          // onChanged: widget.onChange,
          readOnly:widget.isReadOnly,
          onTap: widget._onTap,
          cursorColor: AppColors.colorBlack,
          controller: widget._textController,
          textCapitalization: widget._textInputType == .emailAddress ? .none :  widget._textCapitalization,
          obscureText: widget.isPassword && !hidePassword,
          maxLines: widget.isPassword ? 1: widget._maxLines,
          textAlignVertical: .center,
          onTapOutside: (_)=> FocusManager.instance.primaryFocus?.unfocus(),
          style: widget._hintTextStyle.copyWith(color: Colors.black),
          keyboardType: widget._textInputType,
          validator: widget._validator,
          inputFormatters: widget._inputFormatters,
          autovalidateMode: widget._autoValidateMode ?? AutovalidateMode.disabled,
          decoration: InputDecoration(
            hintStyle: widget._hintTextStyle,
            hintText: widget._hintText,
            labelStyle: AppTextStyles.regularTextStyle,
            errorStyle: AppTextStyles.regularTextStyle.copyWith(color: AppColors.redColor),
            isDense: widget._isDense,
            // fillColor: _focusNode.hasFocus ? AppColors.fillColor : Colors.white,
            // filled: true,
            prefixIconConstraints: BoxConstraints(maxWidth: 50, maxHeight: 50,),
            suffixIconConstraints: BoxConstraints(maxWidth: 50, maxHeight: 50),
            prefixIcon: widget._prefixIcon != null ? Padding(
                padding: .only(left: 19, right: 10), // add padding to adjust icon
                child: SvgPicture.asset(widget._prefixIcon!,width: 20, height: 20, colorFilter: .mode(AppColors.greyTextColor, .srcIn),)
            ) : null,
            suffixIcon: widget.isPassword
                ? GestureDetector(
              onTap: () => setState(() => hidePassword = !hidePassword),
              child: Padding(
                padding: .only(left: 10, right: 20), // add padding to adjust icon
                child: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.greyTextColor,),
              ),)
                : widget._suffixIcon != null
                ? Padding(
              padding: const .only(right: 16.0),
              child: widget._suffixIcon!.endsWith('.svg') ? SvgPicture.asset(widget._suffixIcon!, width: 24, height: 24,): Image.asset(widget._suffixIcon!),
            ) : null,
            enabledBorder: widget._enabledBorder ??  OutlineInputBorder(
              borderRadius: .circular(widget._borderRadius),
              borderSide: BorderSide(color: widget._borderColor),
            ),
            focusedBorder: widget._focusedBorder ??  OutlineInputBorder(
              borderRadius: .circular(widget._borderRadius),
              borderSide: BorderSide(color: widget._focusedBorderColor),
            ),
            errorBorder:  OutlineInputBorder(
              borderRadius: .circular(widget._borderRadius),
              borderSide: BorderSide(color: widget._errorBorderColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: .circular(widget._borderRadius),
              borderSide: BorderSide(color: widget._errorBorderColor),
            ),

          ),
        ),
      ],
    );
    /*return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(widget._titleText.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget._titleText, style: AppTextStyles.regularTextStyle,),
              const SizedBox(height: 5,),
            ],
          ),
        TextField(
          controller: widget._textController,
          style: AppTextStyles.regularTextStyle,
          keyboardType: widget._textInputType,

          readOnly: widget.isReadOnly,
          onTap: widget._onTap,
          onTapOutside: (_)=> FocusManager.instance.primaryFocus?.unfocus(),
          obscureText: widget.isPassword && hidePassword,
          cursorColor: Colors.grey,
          maxLines: widget._maxLines,
          textCapitalization: widget._textInputType == .emailAddress ? .none :  widget._textCapitalization,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            enabledBorder: widget._enabledBorder ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.borderColor)
            ),
            focusedBorder:widget._focusedBorder ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.colorBlack)
            ),
            hintText: widget._hintText,
            hintStyle: widget._hintTextStyle,
            // prefixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            // prefixIcon: widget._prefixIcon.isNotEmpty ? SvgPicture.asset(widget._prefixIcon) : null,
            suffixIcon: widget.isPassword ? IconButton(
                onPressed: () => setState(() => hidePassword = !hidePassword),
                icon: hidePassword
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off)) : widget._suffixIcon,

          ),
        ),
      ],
    );*/
  }
}