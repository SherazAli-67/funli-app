import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_constants.dart';

class WelcomePage extends StatelessWidget{
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: Text(AppConstants.appTitle),)),
    );
  }

}