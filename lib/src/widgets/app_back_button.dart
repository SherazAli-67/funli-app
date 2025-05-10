import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../res/app_icons.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: ()=> Navigator.of(context).pop(),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: SvgPicture.asset(AppIcons.icArrowBack),
        ));
  }
}