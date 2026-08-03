import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../res/app_colors.dart';
import '../res/app_textstyles.dart';
class SocialSignInBtn extends StatelessWidget {
  const SocialSignInBtn({
    super.key,
    required this.btnTitle,
    required this.icon,
    this.onTap
  });

  final String btnTitle;
  final String icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: .circular(99),),
            padding: .symmetric(horizontal: 16, vertical: 14),
          side: BorderSide(color: AppColors.borderColor.withValues(alpha: 0.3)),
          elevation: 0
        ),
        onPressed: onTap ?? (){}, child: Row(
      mainAxisAlignment: .center,
      spacing: 10,
      children: [
        SvgPicture.asset(icon),
        Text(btnTitle, style: AppTextStyles.buttonTextStyle.copyWith(fontSize: 14, color: Colors.black),),
      ],
    ));
  }
}