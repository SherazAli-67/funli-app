import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/helpers/formatting_helpers.dart';
import 'package:funli_app/src/models/mood_model.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:go_router/go_router.dart';

class MoodCarouselCard extends StatelessWidget {
  const MoodCarouselCard({
    super.key,
    required MoodModel mood,
    required List<ReelModel> reels,
    this.showStats = true,
  })  : _mood = mood,
        _reels = reels;

  final MoodModel _mood;
  final List<ReelModel> _reels;
  final bool showStats;

  @override
  Widget build(BuildContext context) {
    final featuredReel = _reels.isNotEmpty ? _reels.first : null;
    final thumbnailUrl =
        featuredReel?.thumbnailUrl ?? AppIcons.icDefaultThumbnailUrl;
    final headline = _resolveHeadline(featuredReel?.caption);
    final viewsCount =
        _reels.fold<int>(0, (sum, reel) => sum + reel.viewsCount);
    final emoji = AppData.getEmojiByMood(_mood.mood);

    return GestureDetector(
      onTap: () => context.push(
        RouterEnum.moodReelsView.routeName,
        extra: {'mood': _mood.mood},
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
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
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.35, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              left: showStats ? 20 : 16,
              right: showStats ? 20 : 16,
              bottom: showStats ? 24 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: showStats ? 10 : 6,
                children: [
                  if (showStats)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.yellowAccentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _mood.mood,
                        style: AppTextStyles.smallBoldTextStyle.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    Text(
                      '$emoji ${_mood.mood.toUpperCase()}',
                      style: AppTextStyles.smallBoldTextStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  Text(
                    headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: (showStats
                            ? AppTextStyles.headingTextStyle3
                            : AppTextStyles.tileTitleTextStyle)
                        .copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  if (showStats)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        _StatRow(
                          icon: Icons.movie_filter_outlined,
                          label:
                              'Total Reels: ${FormatingHelpers.formatNumber(_mood.reelsCount)} streams',
                        ),
                        _StatRow(
                          icon: Icons.visibility_outlined,
                          label:
                              'Views count: ${FormatingHelpers.formatNumber(viewsCount)} Views',
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveHeadline(String? caption) {
    if (caption == null || caption.trim().isEmpty) return _mood.mood;
    final withoutHashtags = caption.split('#').first.trim();
    return withoutHashtags.isNotEmpty ? withoutHashtags : _mood.mood;
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.smallTextStyle.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
