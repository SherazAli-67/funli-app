import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/primary_gradient_background.dart';

class WelcomePage extends StatelessWidget{
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimaryGradientBackground(child: Center(child: Text("Welcome to FUNLI", style: AppTextStyles.headingTextStyle,),));
  }

}