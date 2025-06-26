import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../res/app_icons.dart' show AppIcons;
import '../res/app_textstyles.dart' show AppTextStyles;

class PrivateAccountWidget extends StatelessWidget {
  const PrivateAccountWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Divider(),
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              shape: BoxShape.circle
          ),
          child:  SvgPicture.asset(AppIcons.icPasswordLock, color: Colors.black,),
        ),
        Text("This Account is Private", style: AppTextStyles.subHeadingTextStyle,),
        Text("Follow this account to see their FEELS", style: AppTextStyles.bodyTextStyle, textAlign: TextAlign.center,)
      ],
    );
  }
}