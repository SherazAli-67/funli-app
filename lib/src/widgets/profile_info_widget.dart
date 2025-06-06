import 'package:flutter/material.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';

import '../helpers/formatting_helpers.dart';
import '../res/app_textstyles.dart';
import 'followers_widget.dart';
import 'loading_widget.dart';

class ProfileInfoWidget extends StatelessWidget{
  final String _userID;
  const ProfileInfoWidget({super.key, required String userID, String? profilePicture}) :_userID = userID;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [

        FutureBuilder(future: UserService.getUserByID(userID: _userID), builder: (ctx, snapshot){
          if(snapshot.hasData){
            UserModel user = snapshot.requireData!;
            return Column(
              spacing: 16,
              children: [
                ProfilePictureWidget(profilePicture: user.profilePicture),
                Column(
                  spacing: 8,
                  children: [
                    Text('@${user.userName}',
                      style: AppTextStyles.subHeadingTextStyle.copyWith(
                          fontWeight: FontWeight.w900),),
                    Text("Dancer & Singer", style: AppTextStyles.commentTextStyle,),
                  ],
                ),

                IntrinsicHeight(
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder(
                          future: UserService.getUserPostsCount(userID: _userID),
                          builder: (ctx, snapshot){
                            if(snapshot.hasData){
                              return _buildUserInfoWidget(title: 'Posts', totalCount: snapshot.requireData);
                            }else if(snapshot.connectionState == ConnectionState.waiting){
                              return LoadingWidget();
                            }

                            return SizedBox();
                          }),
                      FutureBuilder(
                          future: UserService.getUserFollowersCount(userID: _userID),
                          builder: (ctx, snapshot){
                            if(snapshot.hasData){
                              return _buildUserInfoWidget(title: 'Followers',
                                  totalCount: snapshot.requireData,
                                  onTap: () => _onFollowersTap(context));
                            }else if(snapshot.connectionState == ConnectionState.waiting){
                              return LoadingWidget();
                            }

                            return SizedBox();
                          }),
                      FutureBuilder(
                          future: UserService.getUserFollowingCount(userID: _userID),
                          builder: (ctx, snapshot){
                            if(snapshot.hasData){
                              return _buildUserInfoWidget(title: 'Following', totalCount: snapshot.requireData,
                                  onTap: () => _onFollowersTap(context, isFollowing: true));
                            }else if(snapshot.connectionState == ConnectionState.waiting){
                              return LoadingWidget();
                            }

                            return SizedBox();
                          }),

                      FutureBuilder(
                          future: UserService.getUserPostsCount(userID: _userID),
                          builder: (ctx, snapshot){
                            if(snapshot.hasData){
                              return _buildUserInfoWidget(title: 'Likes', totalCount: snapshot.requireData, isLast: true);
                            }else if(snapshot.connectionState == ConnectionState.waiting){
                              return LoadingWidget();
                            }

                            return SizedBox();
                          }),

                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        })

      ],
    );
  }

  Widget _buildUserInfoWidget({required int totalCount, required String title, bool isLast = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Column(
            spacing: 4,
            children: [
              Text(FormatingHelpers.formatNumber(totalCount), style: AppTextStyles.headingTextStyle3,),
              Text(title, style: AppTextStyles.commentTextStyle,)
            ],
          ),
          if(!isLast)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: VerticalDivider(),
            )
        ],
      ),
    );
  }


  void _onFollowersTap(BuildContext context, {bool isFollowing = false}){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FollowingAndFollowersBottomSheet(isFollowing: isFollowing,),
    );
  }
}