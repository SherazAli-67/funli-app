import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/features/hashtagged_reels_page/hashtag_reels_widget.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/services/search_service.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/secondary_btn.dart';
import '../models/user_model.dart';
import '../res/app_colors.dart';
import '../res/app_textstyles.dart';
import '../services/user_service.dart';
import '../widgets/loading_widget.dart';

class SearchPage extends StatefulWidget{
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  int selectedIndex = 0;
  List<ReelModel> _reels = [];
  String query = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            child: Column(
              spacing: 10,
              children: [
                SizedBox(
                  height: 48,
                  child: TextField(
                    onChanged: (val){
                      query = val;
                      setState(() {});
                    },
                    onSubmitted: (val){
                      query = val;
                      setState(() {});
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
                        prefixIcon: Icon(Icons.search, color: AppColors.greyTextColor,)
                    ),
                  ),
                ),
                Row(
                  spacing: 5,
                  children: [
                    SizedBox(
                      height: 35,
                      width: 100,
                      child: selectedIndex == 0
                          ?  PrimaryBtn(btnText: "Feels", icon: '', onTap: (){}, bgGradient: AppIcons.primaryBgGradient, textStyle: AppTextStyles.bodyTextStyle,)
                          : SecondaryBtn(btnText: "Feels", icon: '', onTap: ()=> _onSelectFilterTypeTap(0), textStyle: AppTextStyles.bodyTextStyle,),
                    ),

                    SizedBox(
                      height: 35,
                      width: 100,
                      child: selectedIndex == 1
                          ?  PrimaryBtn(btnText: "Users", icon: '', onTap: (){}, bgGradient: AppIcons.primaryBgGradient, textStyle: AppTextStyles.bodyTextStyle,)
                          : SecondaryBtn(btnText: "Users", icon: '', onTap: ()=> _onSelectFilterTypeTap(1), textStyle: AppTextStyles.bodyTextStyle,),
                    ),

                    SizedBox(
                      height: 35,
                      width: 127,
                      child: selectedIndex == 2
                          ?  PrimaryBtn(btnText: "Hashtags", icon: '', onTap: (){}, bgGradient: AppIcons.primaryBgGradient, textStyle: AppTextStyles.bodyTextStyle,)
                          : SecondaryBtn(btnText: "Hashtags", icon: '', onTap: ()=> _onSelectFilterTypeTap(2), textStyle: AppTextStyles.bodyTextStyle,),
                    ),
                  ],
                )
              ],
            ),
          ),
          if(selectedIndex == 0)
            Expanded(child: _buildFeelsSearchWidget()),

          if(selectedIndex == 1)
            Expanded(child: _buildUsersSearchWidget()),

          if(selectedIndex == 2)
            Expanded(child: _buildHashtagSearchWidget())
        ],
      )),
    );
  }

  void _onSelectFilterTypeTap(int index) {
    setState(()=> selectedIndex = index);
  }

  Widget _buildUsersSearchWidget() {
    return Center(child: Text("Users search widget"),);
  }

  Widget _buildFeelsSearchWidget() {
    return FutureBuilder(future: SearchService.getReels(query), builder: (ctx,snapshot){
      if(snapshot.hasData){
        List<ReelModel> reels = snapshot.requireData;
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: reels.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 9 / 16,
          ),
          itemBuilder: (context, index) {
            if (index >= reels.length) {
              return LoadingWidget();
            }
            ReelModel reel = reels[index];
            final thumbnailUrl = reel.thumbnailUrl ?? AppIcons.icDummyImgUrl;

            return GestureDetector(
              onTap: () {
                // open reel detail page if needed
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(thumbnailUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                  ),
                  Positioned(
                      top: 10,
                      left: 5,
                      right: 5,
                      child: FutureBuilder(future: UserService.getUserByID(userID: reel.userID), builder: (ctx, snapshot){
                        if(snapshot.hasData && snapshot.requireData != null){
                          UserModel user = snapshot.requireData!;
                          return Row(
                            spacing: 5,
                            children: [

                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.purpleColor,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 19,
                                  backgroundImage: CachedNetworkImageProvider(user.profilePicture ?? AppIcons.icDummyImgUrl),
                                ),
                              ),
                              Expanded(child: Text(user.userName, style: AppTextStyles.smallTextStyle.copyWith(color: Colors.white),))
                            ],
                          );
                        }

                        return SizedBox();
                      })),
                  Positioned(
                      bottom: 10,
                      left: 10,
                      right: 0,
                      child: Row(
                        spacing: 5,
                        children: [

                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Center(child: Icon(Icons.play_arrow_rounded, ),),
                          ),

                         /* Expanded(
                              child: FutureBuilder(future: ReelsService.getReelViewsCount(reelID: reel.reelID),
                                  builder: (ctx, snapshot) {
                                    if(snapshot.hasData && snapshot.requireData > 0){
                                      return ReelLikesCountWidget(count: snapshot.requireData);
                                    }

                                    return ReelLikesCountWidget();
                                  }))*/
                        ],
                      ))
                ],
              ),
            );
          },
        );
      }else if(snapshot.connectionState == ConnectionState.waiting){
        return LoadingWidget();
      }

      return SizedBox();
    });
  }

  Widget _buildHashtagSearchWidget() {
    return Center(child: Text("Hashtag search widget"),);
  }
}