import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/loading_shimmers/reels_gridview_shimmer.dart';
import 'package:funli_app/src/models/filter_model.dart';
import 'package:funli_app/src/models/hashtag_model.dart';
import 'package:funli_app/src/providers/feels_search_provider.dart';
import 'package:funli_app/src/providers/hashtag_search_provider.dart';
import 'package:funli_app/src/providers/users_search_provider.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/services/search_service.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';
import 'package:funli_app/src/widgets/secondary_btn.dart';
import 'package:funli_app/src/widgets/secondary_gradient_btn.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../helpers/formatting_helpers.dart';
import '../models/user_model.dart';
import '../res/app_colors.dart';
import '../res/app_constants.dart';
import '../res/app_textstyles.dart';
import '../services/hashtag_service.dart';
import '../services/reels_service.dart';
import '../services/user_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/reel_likes_count.dart';

class SearchPage extends StatefulWidget{
  const SearchPage({super.key, this.reelFilter});
  final ReelFilter? reelFilter;
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  int selectedIndex = 0;
  String query = '';
  late FeelsSearchProvider _feelProvider;
  late UsersSearchProvider _userProvider;
  late HashtagSearchProvider _hashtagProvider;

  
  @override
  Widget build(BuildContext context) {
     _userProvider = Provider.of<UsersSearchProvider>(context); // listen: true by default
     _feelProvider = Provider.of<FeelsSearchProvider>(context);
     _hashtagProvider = Provider.of<HashtagSearchProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Results", style: AppTextStyles.headingTextStyle3,),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(onPressed: ()=> context.pop(), icon: Icon(Icons.arrow_back_ios_new_rounded)),
      ),
      body: SafeArea(child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            child: Column(
              spacing: 20,
              children: [
                SizedBox(
                  height: 48,
                  child: TextField(
                    onChanged: (val){
                      if(selectedIndex == 0){
                        val.isEmpty ? _feelProvider.fetchInitial(query: val) : _feelProvider.fetchReelsByQuery(query: val);
                      }else if(selectedIndex == 1){
                        _userProvider.fetchInitial(query: val);
                      }

                    },
                    onSubmitted: (val){
                      if(selectedIndex == 0){
                        val.isEmpty ? _feelProvider.fetchInitial(query: val) : _feelProvider.fetchReelsByQuery(query: val);
                      }else if(selectedIndex == 1){
                        _userProvider.fetchInitial(query: val);
                      }
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                  ),
                ),
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

  Widget _buildUsersSearchWidget() {
    return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _userProvider.fetchMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _userProvider.users.length,

          itemBuilder: (context, index) {
            if (index >= _userProvider.users.length) {
              return LoadingWidget();
            }
            UserModel user = _userProvider.users[index];
            return ListTile(
              onTap: (){
                context.push(RouterEnum.remoteUserProfileView.routeName, extra: {
                  'userID' : user.userID,
                  'userName' : user.userName,
                  'profilePicture' : user.profilePicture
                });

              },
              dense: true,
              horizontalTitleGap: 5,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
              leading: ProfilePictureWidget(profilePicture: user.profilePicture),
              title: Text(user.userName, style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w700),),
              trailing: ConstrainedBox(constraints: BoxConstraints(maxWidth: 120, minWidth: 80), child: StreamBuilder(stream: UserService.getIsFollowingStream(user.userID), builder: (ctx, snapshot){
                if(snapshot.hasData){
                  return snapshot.requireData
                      ? SecondaryGradientBtn(btnText: "Following", icon: '', onTap: (){}, buttonHeight: 38,)
                      : SizedBox(
                    height: 38,
                    width: 75,
                    child: PrimaryBtn(btnText: "Follow", icon: '', onTap: (){}, bgGradient: AppIcons.primaryBgGradient, textStyle: AppTextStyles.smallBoldTextStyle,),
                  );
                }else if(snapshot.connectionState == ConnectionState.waiting){
                  return LoadingWidget();
                }

                return LoadingWidget();
              }),),
            );
          },
        ));
  }

  Widget _buildFeelsSearchWidget() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _feelProvider.fetchMore();
        }
        return false;
      },
      child: _feelProvider.isLoading && _feelProvider.reels.isEmpty ? ReelsGridShimmer() : GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2/3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10
        ),
        itemCount: _feelProvider.reels.length,
        itemBuilder: (ctx, index) {
          final reel =  _feelProvider.reels[index];
          return GestureDetector(
            onTap: () {

              context.push(RouterEnum.updatedReelsView.routeName,   extra: {
                'initialReels': _feelProvider.reels,
                'selectedIndex': index,
                'lastDocument': _feelProvider.lastDoc,
                'comingFrom':  AppConstants.comingFromSearch,
              },);
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(reel.thumbnailUrl!),
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
                            Expanded(child: Text(user.userName, style: AppTextStyles.smallTextStyle.copyWith(color: Colors.white,),))
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

                        Expanded(
                            child: FutureBuilder(future: ReelsService.getReelViewsCount(reelID: reel.reelID),
                                builder: (ctx, snapshot) {
                                  if(snapshot.hasData && snapshot.requireData > 0){
                                    return ReelLikesCountWidget(count: snapshot.requireData);
                                  }

                                  return ReelLikesCountWidget();
                                }))
                      ],
                    ))
              ],
            ),
          );
        },
      ),
    );
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
                        context.push(RouterEnum.hashtagsReelsView.routeName, extra: {
                          'tag' : hashtag.tag
                        });
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


  void _loadInitialData() {
    switch (selectedIndex) {
      case 0:
        _feelProvider.fetchInitial();
        break;
      case 1:
        _userProvider.fetchInitial(query: query);
        break;
      case 2:
        _hashtagProvider.fetchInitial();
        break;
    }
  }


  void _onSelectFilterTypeTap(int index) {
    setState(()=> selectedIndex = index);
    _loadInitialData();
  }
}