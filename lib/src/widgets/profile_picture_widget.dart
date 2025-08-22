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
  }) : _profilePicture = profilePicture;

  final String? _profilePicture;
  final VoidCallback? onTap;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: 35,
      backgroundColor: AppColors.amberYellowColor,
      child: CircleAvatar(
        backgroundColor: AppColors.amberYellowColor,
        radius: _profilePicture  != null ? 33 :22,
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