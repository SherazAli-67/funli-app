import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../res/app_colors.dart';
import '../res/app_icons.dart';

class ProfilePictureWidget extends StatelessWidget {
  const ProfilePictureWidget({
    super.key,
    required String? profilePicture,
    this.onTap,
    this.heroTag,
    this.radius = 35,
    this.childRadius = 33
  }) : _profilePicture = profilePicture;

  final String? _profilePicture;
  final VoidCallback? onTap;
  final String? heroTag;
  final double radius;
  final double childRadius;
  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.amberYellowColor,
      child: CircleAvatar(
        backgroundColor: AppColors.amberYellowColor,
        radius: _profilePicture  != null ? childRadius:15,
        backgroundImage: _profilePicture != null
            ? CachedNetworkImageProvider(_profilePicture)
            : CachedNetworkImageProvider(AppIcons.icDummyImgUrl),
      ),
    );

    if (heroTag != null && heroTag!.isNotEmpty) {
      avatar = Hero(tag: heroTag!, child: avatar);
    }

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }
}