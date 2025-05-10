import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_gradients.dart';

class PrimaryGradientBackground extends StatelessWidget {
  const PrimaryGradientBackground({super.key, required this.child, this.width = double.infinity, this.height= double.infinity});
  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allows body to extend behind AppBar if you use one
      // extendBodyBehindAppBar: true,
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient
        ),
        child: child
      ),
    );
  }
}