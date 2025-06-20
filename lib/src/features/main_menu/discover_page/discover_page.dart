import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/features/main_menu/discover_page/filter_bottomsheet.dart';
import 'package:funli_app/src/helpers/formatting_helpers.dart';
import 'package:funli_app/src/loading_shimmers/trending_feels_widget.dart';
import 'package:funli_app/src/models/mood_model.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/hashtag_service.dart';
import 'package:funli_app/src/widgets/gradient_icon.dart';
import 'package:funli_app/src/widgets/gradient_text_widget.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/secondary_gradient_btn.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../loading_shimmers/reel_thumbnail_shimmer_item.dart';
import '../../../loading_shimmers/trending_hashtag_shimmer.dart';
import '../../../models/filter_model.dart';
import '../../../providers/discover_provider.dart';

class DiscoverPage extends StatefulWidget{
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {

  ReelFilter currentFilter = ReelFilter();

  final TextEditingController locationTextEditingController = TextEditingController();
  final TextEditingController languageTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final discoverProvider = Provider.of<DiscoverProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text("Discover", style: AppTextStyles.headingTextStyle3),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final newFilter = await showFilterBottomSheet(currentFilter);
              if (newFilter != null) {
                context.push(RouterEnum.filteredReelsView.routeName, extra: {
                  'filter': newFilter,
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greyFillColor,
              elevation: 0,
            ),
            child: Row(
              children: [
                SvgPicture.asset(AppIcons.icFilter),
                SizedBox(width: 6),
                Text("Filter", style: AppTextStyles.smallTextStyle),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
          child: ListView(
            children: [
              // 🔍 Search Field
              TextField(
                readOnly: true,
                onTap: () => context.push(RouterEnum.searchView.routeName),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.searchFillColor,
                  hintText: 'Search users, feels, trends, hashtags',
                  hintStyle: AppTextStyles.hintTextStyle,
                  prefixIcon: Icon(Icons.search, color: AppColors.greyTextColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 20),
              Text("Trending Hashtags",
                  style: AppTextStyles.buttonTextStyle.copyWith(fontWeight: FontWeight.w700)),

              const SizedBox(height: 10),

              discoverProvider.isLoadingHashtags
                  ? Column(
                children: List.generate(4, (_) => TrendingHashtagShimmerWidget()),
              )
                  : Column(
                children: discoverProvider.trendingHashtags.map((hashtag) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push(RouterEnum.hashtagsReelsView.routeName, extra: {'tag': hashtag.tag}),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "#${hashtag.tag}  ",
                                    style: AppTextStyles.smallTextStyle.copyWith(fontWeight: FontWeight.w700, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: "${FormatingHelpers.formatNumber(hashtag.reelsCount)} feels",
                                    style: AppTextStyles.smallTextStyle.copyWith(color: AppColors.hashtagCountGreyColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        StreamBuilder<bool>(
                            stream: HashtagService.getIsFollowing(
                                hashtag: hashtag.tag),
                            builder: (ctx, snapshot) {
                              if (snapshot.hasData) {
                                bool isFollowing = snapshot.requireData;
                                return isFollowing
                                    ? SecondaryGradientBtn(btnText: "Following", icon: '',
                                  onTap: () => HashtagService.oddToFollow(hashtag: hashtag.tag, isUnfollowRequest: true), buttonHeight: 35, )
                                    : SizedBox(
                                    height: 35,
                                    width: 80,
                                    child: PrimaryBtn(
                                      btnText: "Follow",
                                      icon: '',
                                      textStyle: AppTextStyles.smallBoldTextStyle,
                                      onTap: () => HashtagService.oddToFollow(hashtag: hashtag.tag), bgGradient: AppIcons.primaryBgGradient,));
                              }

                              return SizedBox();
                            })
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              Text("Trending Feels",
                  style: AppTextStyles.buttonTextStyle.copyWith(fontWeight: FontWeight.w700)),

              const SizedBox(height: 20),

              discoverProvider.isLoadingMoods
                  ? TrendingFeelsShimmerWidget()
                  : Column(
                children: discoverProvider.trendingMoods.map((mood) {
                  return MoodCard(mood: mood); // 🔄 Move this logic to a reusable widget
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<ReelFilter?> showFilterBottomSheet(ReelFilter currentFilter) {
    return showModalBottomSheet<ReelFilter>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(currentFilter: currentFilter),
    );
  }
}

class MoodCard extends StatelessWidget {
  final MoodModel mood;
  const MoodCard({required this.mood, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        spacing: 10,
        children: [
          ListTile(
            onTap: () => _onMoodTap(context, mood.mood),
            leading: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.yellowAccentColor
              ),
              padding: EdgeInsets.all(5),
              child: Text(AppData.getEmojiByMood(mood.mood),
                style: TextStyle(fontSize: 30),),
            ),
            title: Text(mood.mood,
              style: AppTextStyles.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w700),),
            subtitle: Text('${mood.reelsCount} feels',
              style: AppTextStyles.captionTextStyle
                  .copyWith(fontWeight: FontWeight.w300,
                  color: AppColors.hintTextColor),),
            trailing: GestureDetector(
              onTap: () => _onMoodTap(context, mood.mood),
              child: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      GradientTextWidget(
                        gradient: AppGradients
                            .primaryGradient,
                        text: "SEE ALL",
                        textStyle: AppTextStyles
                            .buttonTextStyle.copyWith(
                            fontWeight: FontWeight
                                .w700),),
                      GradientIcon(
                          icon: Icons.navigate_next_sharp,
                          size: 30,
                          gradient: AppGradients
                              .primaryGradient),
                    ],
                  )
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 10),
          ),


          SizedBox(
            height: 200,
            width: double.infinity,
            child: Consumer<DiscoverProvider>(
              builder: (ctx, provider, child) {
                List<ReelModel> reels = provider.moodReels[mood.mood] ?? [];
                DocumentSnapshot? lastDoc = provider.moodLastDocuments[mood.mood];
                if (reels.isNotEmpty) {
                  return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: mood.reelsCount > reels.length ? (reels.length + 1) : reels.length,
                      itemBuilder: (ctx, index) {
                        return index == reels.length
                            ? IconButton(
                                style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(side: BorderSide.none),
                                    backgroundColor: AppColors.yellowAccentColor,
                                    padding: EdgeInsets.all(20)),
                                onPressed: () {
                                  _onMoodTap(context, mood.mood);
                                },
                                icon: Icon(Icons.arrow_forward_rounded, size: 30))
                            : GestureDetector(
                                onTap: () {
                                  context.push(
                                    RouterEnum.updatedReelsView.routeName,
                                    extra: {
                                      'initialReels': reels,
                                      'selectedIndex': index,
                                      'lastDocument': lastDoc,
                                      'comingFrom': AppConstants.comingFromMood,
                                      'mood': mood.mood,
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => ReelThumbnailShimmerItem(),
                                      imageUrl: reels[index].thumbnailUrl ?? AppIcons.icDummyImgUrl,
                                      height: 150,
                                    ),
                                  ),
                                ),
                              );
                      });
                } else if (provider.isLoadingMoods) {
                  return LoadingWidget();
                }
                return SizedBox();
              },
            ),
          )
        ],
      ),
    );
  }

  void _onMoodTap(BuildContext context, String mood){
    context.push(RouterEnum.moodReelsView.routeName, extra: {'mood' : mood});
  }
}
