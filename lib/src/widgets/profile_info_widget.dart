import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';

import '../helpers/formatting_helpers.dart';
import '../res/app_textstyles.dart';
import 'loading_widget.dart';

class ProfileInfoWidget extends StatelessWidget{
  final String _userID;
  final String? _profilePicture;
  const ProfileInfoWidget({super.key, required String userID, String? profilePicture}) :_userID = userID, _profilePicture = profilePicture;
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
                              return _buildUserInfoWidget(title: 'Followers', totalCount: snapshot.requireData);
                            }else if(snapshot.connectionState == ConnectionState.waiting){
                              return LoadingWidget();
                            }

                            return SizedBox();
                          }),
                      FutureBuilder(
                          future: UserService.getUserFollowingCount(userID: _userID),
                          builder: (ctx, snapshot){
                            if(snapshot.hasData){
                              return _buildUserInfoWidget(title: 'Following', totalCount: snapshot.requireData);
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

  Widget _buildUserInfoWidget({required int totalCount, required String title, bool isLast = false}) {
    return Row(
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
    );
  }
}

