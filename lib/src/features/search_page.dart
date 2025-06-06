import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/features/main_menu/profile/remote_user_profile_page.dart';
import 'package:funli_app/src/models/hashtag_model.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/services/search_service.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';
import 'package:funli_app/src/widgets/secondary_btn.dart';
import 'package:funli_app/src/widgets/secondary_gradient_btn.dart';
import '../helpers/formatting_helpers.dart';
import '../models/user_model.dart';
import '../res/app_colors.dart';
import '../res/app_constants.dart';
import '../res/app_textstyles.dart';
import '../services/hashtag_service.dart';
import '../services/user_service.dart';
import '../widgets/loading_widget.dart';
import 'hashtagged_reels_page/hashtag_reels_page.dart';

class SearchPage extends StatefulWidget{
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  int selectedIndex = 0;
  // List<ReelModel> _reels = [];
  String query = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Results", style: AppTextStyles.headingTextStyle3,),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
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
                    textCapitalization: TextCapitalization.words,
                    onTapOutside: (val)=> FocusManager.instance.primaryFocus!.unfocus(),
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
            Expanded(child:   _buildHashtagSearchWidget() )
        ],
      )),
    );
  }

  void _onSelectFilterTypeTap(int index) {
    setState(()=> selectedIndex = index);
  }

  Widget _buildUsersSearchWidget() {
    return FutureBuilder(future: SearchService.getUsers(query), builder: (ctx,snapshot){
      if(snapshot.hasData){
        List<UserModel> users = snapshot.requireData;
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: users.length,
         
          itemBuilder: (context, index) {
            if (index >= users.length) {
              return LoadingWidget();
            }
            UserModel user = users[index];
            return ListTile(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> RemoteUserProfilePage(userID: user.userID, userName: user.userName, profilePicture: user.profilePicture,)));
              },
              contentPadding: EdgeInsets.zero,
              leading: ProfilePictureWidget(profilePicture: user.profilePicture),
              title: Text(user.userName, style: AppTextStyles.buttonTextStyle,),
              trailing: SizedBox(

                width: 100,
                child: StreamBuilder(stream: UserService.getIsFollowingStream(user.userID), builder: (ctx, snapshot){
                  if(snapshot.hasData){
                    return snapshot.requireData
                        ? SecondaryGradientBtn(btnText: "Following", icon: '', onTap: (){}, buttonHeight: 38,)
                        : SizedBox(
                      height: 38,
                      width: 75,
                      child: PrimaryBtn(btnText: "Follow", icon: '', onTap: (){}, bgGradient: AppIcons.primaryBgGradient,),
                    );
                  }else if(snapshot.connectionState == ConnectionState.waiting){
                    return LoadingWidget();
                  }

                  return LoadingWidget();
                }),
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

  Widget _buildFeelsSearchWidget() {
    return StreamBuilder(stream: SearchService.getReelsStream(query), builder: (ctx,snapshot){
      if(snapshot.hasData){
        List<ReelModel> reels = snapshot.requireData;
        debugPrint("Reels found ${reels.length} for $query");
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
    return StreamBuilder(stream: SearchService.getTags(query), builder: (ctx,snapshot){
      if(snapshot.hasData){
        List<HashtagModel> tags = snapshot.requireData;
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: tags.length,
          itemBuilder: (context, index) {
            if (index >= tags.length) {
              return LoadingWidget();
            }
            HashtagModel hashtag = tags[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> HashtagReelsPage(hashtag: hashtag.tag)));
                      },
                      child: RichText(text: TextSpan(
                        children: [
                          TextSpan(text: "#${hashtag.tag}  ", style: AppTextStyles.smallTextStyle.copyWith(fontWeight: FontWeight.w700, fontFamily: AppConstants.appFontFamily, color: Colors.black),),
                          TextSpan(text: "${FormatingHelpers.formatNumber(hashtag.reelsCount)} feels ", style: AppTextStyles.smallTextStyle.copyWith(fontFamily: AppConstants.appFontFamily, color: AppColors.hashtagCountGreyColor),),
                        ],

                      )),
                    ),
                  ),
                  StreamBuilder(stream: HashtagService.getIsFollowing(hashtag: hashtag.tag), builder: (ctx, snapshot){
                    if(snapshot.hasData){
                      bool isFollowing = snapshot.requireData;
                      return isFollowing
                          ? SecondaryGradientBtn(btnText: "Following", icon: '', onTap: ()=> HashtagService.oddToFollow(hashtag: hashtag.tag, isUnfollowRequest: true), buttonHeight: 40,)
                          : SizedBox(
                          height: 40,
                          width: 100,
                          child: PrimaryBtn(btnText: "Follow", icon: '', onTap: ()=>HashtagService.oddToFollow(hashtag: hashtag.tag), bgGradient: AppIcons.primaryBgGradient,));
                    }

                    return SizedBox();
                  })
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
}