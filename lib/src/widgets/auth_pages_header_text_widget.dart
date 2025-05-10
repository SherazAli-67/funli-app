import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../res/app_icons.dart';
import '../res/app_textstyles.dart';
import '../res/spacing_constants.dart';

class AuthPagesHeaderTextWidget extends StatelessWidget {
  const AuthPagesHeaderTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 65,
        left: SpacingConstants.screenHorizontalPadding,
        right: SpacingConstants.screenHorizontalPadding,
      ),
      child: Column(children: [
        SvgPicture.asset(AppIcons.icFunliHeaderLogo),
        Text("Capture your mood and share your vibe.", style: AppTextStyles.buttonTextStyle,),
        const SizedBox(height: 60,),
      ]),
    );
  }
}