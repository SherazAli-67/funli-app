import 'package:flutter/material.dart';

class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient gradient;

  const GradientIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return gradient.createShader(Rect.fromLTWH(0, 0, size, size));
      },
      child: Icon(
        icon,
        size: size,
        color: Colors.white, // Required for ShaderMask to work
      ),
    );
  }
}