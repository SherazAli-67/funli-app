import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_icons.dart';

class PostShareWidget extends StatelessWidget{
  final Color iconColor;
  final ReelModel reel;
  final VoidCallback onShareTap;
  const PostShareWidget({super.key, required this.onShareTap, this.iconColor = Colors.grey, required this.reel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onShareTap,
          icon: SvgPicture.asset(
            AppIcons.icShare,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

}
