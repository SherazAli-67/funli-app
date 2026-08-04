import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LiquidGlassIconWidget extends StatelessWidget{
  const LiquidGlassIconWidget({super.key, required this.icon, this.iconColor = Colors.white});
  final String icon;
  final Color iconColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        shape: .circle
      ),
      padding: const EdgeInsets.all(8.0),
      child:  GestureDetector(onTap: (){},
        child: SvgPicture.asset(icon,
          height: 24,
          width: 24,
          colorFilter:  ColorFilter
              .mode(
              iconColor, BlendMode.srcIn),),

      ),
    );
  }
}