import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      child: SvgPicture.asset(AppIcons.icFunliHeaderLogo, height: size.height*0.25,),
    );
  }
}