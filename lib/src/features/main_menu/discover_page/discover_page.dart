import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/features/hashtagged_reels_page/hashtag_reels_page.dart';
import 'package:funli_app/src/features/main_menu/discover_page/filter_bottomsheet.dart';
import 'package:funli_app/src/features/main_menu/discover_page/filtered_reels_page.dart';
import 'package:funli_app/src/features/mood_reels_page/mood_reels_page.dart';
import 'package:funli_app/src/features/search_page.dart';
import 'package:funli_app/src/helpers/formatting_helpers.dart';
import 'package:funli_app/src/models/hashtag_model.dart';
import 'package:funli_app/src/models/mood_model.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/hashtag_service.dart';
import 'package:funli_app/src/services/mood_service.dart';
import 'package:funli_app/src/widgets/gradient_icon.dart';
import 'package:funli_app/src/widgets/gradient_text_widget.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/secondary_gradient_btn.dart';

import '../../../models/filter_model.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text("Discover", style: AppTextStyles.headingTextStyle3,),
        centerTitle: false,
       /* leading: IconButton(
            onPressed: () {}, icon: Icon(Icons.arrow_back_ios_new_rounded)),*/
        leadingWidth: 30,
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greyFillColor,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  elevation: 0
              ),
              onPressed: () async {
                final newFilter = await showFilterBottomSheet(
                    context, currentFilter);
               if(newFilter != null){
                 Navigator.of(context).push(MaterialPageRoute(builder: (_)=> FilteredReelsPage(filter: newFilter)));
               }
              }, child: Row(
            spacing: 10,
            children: [
              SvgPicture.asset(AppIcons.icFilter),
              Text("Filter", style: AppTextStyles.smallTextStyle,)
            ],
          ))
        ],
      ),
      body: SafeArea(child: _buildDiscoverWidget(context)),
    );
  }

  Widget _buildDiscoverWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 18, top: 8, bottom: 100),
      child: ListView(
        children: [
          TextField(
            readOnly: true,
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => SearchPage()));
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.searchFillColor,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.transparent)
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.transparent)
              ),
              hintText: 'Search users, feels, trends, hashtags',
              hintStyle: AppTextStyles.hintTextStyle,
              prefixIcon: Icon(Icons.search, color: AppColors.greyTextColor,),
            ),
          ),
          const SizedBox(height: 20,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Trending Hashtags",
                style: AppTextStyles.buttonTextStyle.copyWith(
                    fontWeight: FontWeight.w700),),
              FutureBuilder(future: HashtagService.getTrendingHashtags(),
                  builder: (ctx, snapshot) {
                    if (snapshot.hasData) {
                      List<HashtagModel> trendingHashtags = snapshot
                          .requireData;
                      return Column(
                        children: trendingHashtags.map((hashtag) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (ctx) =>
                                              HashtagReelsPage(
                                                  hashtag: hashtag.tag)));
                                    },
                                    child: RichText(text: TextSpan(
                                      children: [
                                        TextSpan(text: "#${hashtag.tag}  ",
                                          style: AppTextStyles.smallTextStyle
                                              .copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontFamily: AppConstants
                                                  .appFontFamily,
                                              color: Colors.black),),
                                        TextSpan(text: "${FormatingHelpers
                                            .formatNumber(
                                            hashtag.reelsCount)} feels ",
                                          style: AppTextStyles.smallTextStyle
                                              .copyWith(
                                              fontFamily: AppConstants
                                                  .appFontFamily,
                                              color: AppColors
                                                  .hashtagCountGreyColor),),
                                      ],

                                    )),
                                  ),
                                ),
                                StreamBuilder(
                                    stream: HashtagService.getIsFollowing(
                                        hashtag: hashtag.tag),
                                    builder: (ctx, snapshot) {
                                      if (snapshot.hasData) {
                                        bool isFollowing = snapshot
                                            .requireData;
                                        return isFollowing
                                            ? SecondaryGradientBtn(
                                          btnText: "Following",
                                          icon: '',
                                          onTap: () =>
                                              HashtagService.oddToFollow(
                                                  hashtag: hashtag.tag,
                                                  isUnfollowRequest: true),
                                          buttonHeight: 40,)
                                            : SizedBox(
                                            height: 40,
                                            width: 100,
                                            child: PrimaryBtn(
                                              btnText: "Follow",
                                              icon: '',
                                              onTap: () =>
                                                  HashtagService.oddToFollow(
                                                      hashtag: hashtag.tag),
                                              bgGradient: AppIcons
                                                  .primaryBgGradient,));
                                      }

                                      return SizedBox();
                                    })
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }
                    else
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingWidget(color: AppColors.purpleColor,);
                    }

                    return SizedBox();
                  })

            ],
          ),
          const SizedBox(height: 20,),
          Text("Trending Feels",
            style: AppTextStyles.buttonTextStyle.copyWith(
                fontWeight: FontWeight.w700),),
          const SizedBox(height: 20,),
          FutureBuilder(future: HashtagService.getTrendingMoods(),
              builder: (ctx, snapshot) {
                if (snapshot.hasData) {
                  List<MoodModel> trendingMoods = snapshot.requireData;
                  return Column(
                      children: trendingMoods.map((mood) {
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
                                child: FutureBuilder(
                                    future: MoodService.getReelsbyMood(
                                        mood: mood.mood),
                                    builder: (ctx, snapshot) {
                                      if (snapshot.hasData) {
                                        return ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: snapshot.requireData
                                                .length,
                                            itemBuilder: (ctx, index) {
                                              ReelModel reel = snapshot
                                                  .requireData[index];
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                    5),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius
                                                      .circular(10),
                                                  child: CachedNetworkImage(
                                                    imageUrl: reel
                                                        .thumbnailUrl ??
                                                        AppIcons
                                                            .icDummyImgUrl,
                                                    height: 150,),
                                                ),
                                              );
                                            });
                                      } else if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return LoadingWidget();
                                      }

                                      return SizedBox();
                                    }),
                              )
                            ],
                          ),
                        );
                      }).toList()
                  );
                }
                else
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingWidget(color: AppColors.purpleColor,);
                }

                return SizedBox();
              }),
        ],
      ),
    );
  }

  Center _buildFeaturesCommenttedWidget() => Center(child: Text(
    "Set to comment due to development of other features",
    style: AppTextStyles.bodyTextStyle, textAlign: TextAlign.center,),);

  void _onMoodTap(BuildContext context, String mood) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MoodReelsPage(mood: mood)));
  }

  Future<ReelFilter?> showFilterBottomSheet(BuildContext context, ReelFilter currentFilter) {
    return showModalBottomSheet<ReelFilter>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) {
      return FilterBottomSheet(currentFilter: currentFilter);
      },
    );
  }
}

