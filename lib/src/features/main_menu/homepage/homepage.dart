import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/providers/discover_provider.dart';
import 'package:funli_app/src/widgets/mood_carousel_card.dart';
import 'package:funli_app/src/widgets/user_profile_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(16),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 16,
        children: [
          UserProfileWidget(),
          Expanded(
            child: Consumer<DiscoverProvider>(
              builder: (context, provider, _) {
                final isLoading =
                    provider.isLoadingMoods && provider.trendingMoods.isEmpty;
                final moods = provider.trendingMoods;

                return CarouselSlider(
                  items: isLoading
                      ? List.generate(provider.trendingMoods.length, (_) => const _MoodCarouselShimmer())
                      : moods.map((mood) => MoodCarouselCard(mood: mood, reels: provider.moodReels[mood.mood] ?? const [],),).toList(),
                  options: CarouselOptions(
                    aspectRatio: 3 / 4,
                    viewportFraction: 0.88,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    reverse: false,
                    autoPlay: false,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.3,
                    scrollDirection: .horizontal,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodCarouselShimmer extends StatelessWidget {
  const _MoodCarouselShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: .circular(24),
        ),
      ),
    );
  }
}
