import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';

class GradientRingAvatar extends StatelessWidget {
  const GradientRingAvatar({
    super.key,
    required this.profilePicture,
    this.radius = 36,
    this.ringWidth = 3,
    this.onTap,
  });

  final String? profilePicture;
  final double radius;
  final double ringWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final innerRadius = radius - ringWidth - 2;

    Widget avatar = Container(
      width: radius * 2,
      height: radius * 2,
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.vibeSeekerRingGradient,
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: CircleAvatar(
          radius: innerRadius,
          backgroundImage: CachedNetworkImageProvider(
            profilePicture ?? AppIcons.icDummyImgUrl,
          ),
        ),
      ),
    );

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }
}
