import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/features/main_menu/discover_page/filter_bottomsheet.dart';
import 'package:funli_app/src/models/filter_model.dart';
import 'package:funli_app/src/models/mood_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/providers/discover_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/explore_reel_tile.dart';
import 'package:funli_app/src/widgets/gradient_ring_avatar.dart';
import 'package:funli_app/src/widgets/mood_carousel_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  ReelFilter currentFilter = ReelFilter();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (current >= maxScroll - 240) {
      context.read<DiscoverProvider>().loadMoreRecentReels();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text('Discover', style: AppTextStyles.headingTextStyle3),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final newFilter = await showFilterBottomSheet(currentFilter);
              if (newFilter != null && context.mounted) {
                context.push(RouterEnum.filteredReelsView.routeName, extra: {'filter': newFilter,});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greyFillColor,
              elevation: 0,
            ),
            child: Row(
              children: [
                SvgPicture.asset(AppIcons.icFilter),
                const SizedBox(width: 6),
                Text('Filter', style: AppTextStyles.smallTextStyle),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<DiscoverProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                  sliver: SliverToBoxAdapter(
                    child: TextField(
                      readOnly: true,
                      onTap: () =>
                          context.push(RouterEnum.searchView.routeName),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.searchFillColor,
                        hintText: 'Search users, feels, trends, hashtags',
                        hintStyle: AppTextStyles.hintTextStyle,
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.greyTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: _TrendingVibesSection(provider: provider),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                SliverToBoxAdapter(
                  child: _TopVibeSeekersSection(provider: provider),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Explore Now',
                      style: AppTextStyles.buttonTextStyle
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                if (provider.isLoadingRecent && provider.recentReels.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: SliverToBoxAdapter(
                      child: _ExploreShimmerGrid(),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childCount: provider.recentReels.length,
                      itemBuilder: (context, index) {
                        final reel = provider.recentReels[index];
                        final height = index.isEven ? 240.0 : 300.0;
                        return ExploreReelTile(
                          reel: reel,
                          height: height,
                          onTap: () => _openReel(provider, index),
                        );
                      },
                    ),
                  ),
                if (provider.isLoadingMoreRecent)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openReel(DiscoverProvider provider, int index) {
    context.push(
      RouterEnum.updatedReelsView.routeName,
      extra: {
        'initialReels': provider.recentReels,
        'selectedIndex': index,
        'lastDocument': provider.recentLastDocument,
        'comingFrom': AppConstants.comingFromSearch,
      },
    );
  }

  Future<ReelFilter?> showFilterBottomSheet(ReelFilter currentFilter) {
    return showModalBottomSheet<ReelFilter>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(currentFilter: currentFilter),
    );
  }
}

class _TrendingVibesSection extends StatelessWidget {
  const _TrendingVibesSection({required this.provider});

  final DiscoverProvider provider;

  @override
  Widget build(BuildContext context) {
    final moods = provider.trendingMoods;
    final isLoading = provider.isLoadingMoods && moods.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending Vibes',
                style: AppTextStyles.buttonTextStyle
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              if (moods.isNotEmpty)
                GestureDetector(
                  onTap: () => context.push(
                    RouterEnum.moodReelsView.routeName,
                    extra: {'mood': moods.first.mood},
                  ),
                  child: Text(
                    'VIEW ALL',
                    style: AppTextStyles.smallBoldTextStyle.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 260,
          child: isLoading
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => const _VibeCardShimmer(),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: moods.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final MoodModel mood = moods[index];
                    return SizedBox(
                      width: 180,
                      child: MoodCarouselCard(
                        mood: mood,
                        reels: provider.moodReels[mood.mood] ?? const [],
                        showStats: false,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TopVibeSeekersSection extends StatelessWidget {
  const _TopVibeSeekersSection({required this.provider});

  final DiscoverProvider provider;

  @override
  Widget build(BuildContext context) {
    final seekers = provider.topVibeSeekers;
    final isLoading = provider.isLoadingSeekers && seekers.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Top VibeSeekers',
            style: AppTextStyles.buttonTextStyle
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: isLoading
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, __) => const _SeekerShimmer(),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: seekers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final UserModel user = seekers[index];
                    return SizedBox(
                      width: 76,
                      child: Column(
                        children: [
                          GradientRingAvatar(
                            profilePicture: user.profilePicture,
                            radius: 34,
                            onTap: () => context.push(
                              RouterEnum.remoteUserProfileView.routeName,
                              extra: {
                                'userID': user.userID,
                                'userName': user.userName,
                                'profilePicture': user.profilePicture,
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '@${user.userName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.smallTextStyle.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ExploreShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: index.isEven ? 240 : 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

class _VibeCardShimmer extends StatelessWidget {
  const _VibeCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

class _SeekerShimmer extends StatelessWidget {
  const _SeekerShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          const CircleAvatar(radius: 34, backgroundColor: Colors.white),
          const SizedBox(height: 8),
          Container(
            width: 56,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
