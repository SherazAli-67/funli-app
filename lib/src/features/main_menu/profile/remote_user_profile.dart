import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/helpers/formatting_helpers.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/secondary_gradient_btn.dart';

class RemoteUserProfile extends StatelessWidget{
  const RemoteUserProfile({super.key, String? userName, String? userID, String? profilePicture}): _userID = userID, _userName = userName, _profilePicture = profilePicture;
  final String? _userName;
  final String? _userID;
  final String? _profilePicture;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.lightGreyColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99)
                  )
                ),
                onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.close)),
          ),
          Column(
            spacing: 16,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.amberYellowColor,
                child: CircleAvatar(
                  backgroundColor: AppColors.amberYellowColor,
                  radius: 35,
                  backgroundImage: _profilePicture != null ? CachedNetworkImageProvider(_profilePicture) : CachedNetworkImageProvider(AppIcons.icDummyImgUrl),
                ),
              ),
              Column(
                spacing: 8,
                children: [
                  Text('@${_userName ?? ''}', style: AppTextStyles.subHeadingTextStyle.copyWith(fontWeight: FontWeight.w900),),
                  Text("Dancer & Singer", style: AppTextStyles.commentTextStyle,)
                ],
              ),
              IntrinsicHeight(
                child: Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildUserInfoWidget(title: 'Posts', totalCount: 823),
                    _buildUserInfoWidget(title: 'Followers', totalCount: 370000),
      
                    _buildUserInfoWidget(title: 'Following', totalCount: 925),
                    _buildUserInfoWidget(title: 'Likes', totalCount: 3900000, isLast: true),
      
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 45,
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(child: PrimaryBtn(btnText: "Follow",isPrefix: true, icon: AppIcons.icAddUser, onTap: (){}, bgGradient: AppIcons.primaryBgGradient,)),
                      Expanded(child: SecondaryGradientBtn(btnText: "Message",isPrefix: true, icon: AppIcons.gradientChatIcon, onTap: (){}, )),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text("Recent Feels", style: AppTextStyles.headingTextStyle3,)),
              ),
              SizedBox(
                height: 200,
                child: FutureBuilder(future: ReelsService.getUserReels(limit: 10), builder: (ctx, snapshot){
      
                  if(snapshot.hasData){
                    return ListView.builder(
                        itemCount: snapshot.requireData.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index){
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CachedNetworkImage(imageUrl: AppIcons.icDummyImgUrl, fit: BoxFit.cover,),
                          );
                    });
                  }else if(snapshot.connectionState == ConnectionState.waiting){
                    return LoadingWidget();
                  }
      
                  return SizedBox();
                }),
              )
            ],
          )
        ],
      ),
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