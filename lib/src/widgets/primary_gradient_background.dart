import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_icons.dart';

class PrimaryGradientBackground extends StatelessWidget {
  const PrimaryGradientBackground({super.key, required this.child,});
  final Widget child;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allows body to extend behind AppBar if you use one
      // extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.asset(AppIcons.primaryBgGradient, fit: BoxFit.cover, width: double.infinity,),
          child
        ],
      )

      /*Container(
        height: height,
        width: width,
        *//*decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient
        ),*//*
        child:
      ),*/
    );
  }
}