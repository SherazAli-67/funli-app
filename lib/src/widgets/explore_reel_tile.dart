import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/helpers/formatting_helpers.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';

import '../models/user_model.dart';
import '../res/app_colors.dart';
import '../services/user_service.dart';

class ExploreReelTile extends StatelessWidget {
  const ExploreReelTile({
    super.key,
    required this.reel,
    required this.onTap,
    this.height = 220,
  });

  final ReelModel reel;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final views = reel.viewsCount > 0
        ? FormatingHelpers.formatNumber(reel.viewsCount)
        : null;
    final caption = reel.caption.trim();

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: reel.thumbnailUrl ?? AppIcons.icDefaultThumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[300]),
                errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl: AppIcons.icDummyImgUrl,
                  fit: BoxFit.cover,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              if (views != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: FutureBuilder(future: UserService.getUserByID(userID: reel.userID), builder: (ctx, snapshot){
                    if(snapshot.hasData && snapshot.requireData != null){
                      UserModel user = snapshot.requireData!;
                      return Row(
                        spacing: 5,
                        children: [

                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryColor,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 19,
                              backgroundImage: CachedNetworkImageProvider(user.profilePicture ?? AppIcons.icDummyImgUrl),
                            ),
                          ),
                          Text(user.userName, style: AppTextStyles.smallTextStyle.copyWith(color: Colors.white,),)
                        ],
                      );
                    }

                    return SizedBox();
                  }),
                ),
              if (caption.isNotEmpty)
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 12,
                  child: Text(
                    caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.smallTextStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),

              if (views != null)
              Positioned(
                right: 10,
                bottom: 12,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 14),
                      Text(
                        '$views',
                        style: AppTextStyles.smallBoldTextStyle.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
