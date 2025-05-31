import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../res/app_colors.dart';
import '../res/app_icons.dart';

class ProfilePictureWidget extends StatelessWidget {
  const ProfilePictureWidget({
    super.key,
    required String? profilePicture,
  }) : _profilePicture = profilePicture;

  final String? _profilePicture;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.amberYellowColor,
      child: CircleAvatar(
        backgroundColor: AppColors.amberYellowColor,
        radius: 35,
        backgroundImage: _profilePicture != null
            ? CachedNetworkImageProvider(_profilePicture)
            : CachedNetworkImageProvider(AppIcons.icDummyImgUrl),
      ),
    );
  }
}