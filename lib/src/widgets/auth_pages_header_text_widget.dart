import 'package:flutter/material.dart';
import '../res/app_icons.dart';
import '../res/spacing_constants.dart';

class AuthPagesHeaderTextWidget extends StatelessWidget {
  const AuthPagesHeaderTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: 30,
        left: SpacingConstants.screenHorizontalPadding,
        right: SpacingConstants.screenHorizontalPadding,
      ),
      child: Image.asset(AppIcons.icSplashLogo, height: size.height*0.25,),
    );
  }
}