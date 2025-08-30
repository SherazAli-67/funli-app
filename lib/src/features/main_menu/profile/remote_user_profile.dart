import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/models/follow_model.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/gradient_text_widget.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/private_account_widget.dart';
import 'package:funli_app/src/widgets/profile_info_widget.dart';
import 'package:go_router/go_router.dart';

import '../../../loading_shimmers/reel_thumbnail_shimmer_item.dart';

class RemoteUserProfileInfoWidget extends StatefulWidget{
  const RemoteUserProfileInfoWidget(
      {super.key, String? userName, required String userID, String? profilePicture, bool isFromProfilePage = false,})
      : _userID = userID,
        _userName = userName,
        _profilePicture = profilePicture,
        _isFromProfilePage = isFromProfilePage;

  final String? _userName;
  final String _userID;
  final String? _profilePicture;
  final bool _isFromProfilePage;

  @override
  State<RemoteUserProfileInfoWidget> createState() => _RemoteUserProfileInfoWidgetState();
}

class _RemoteUserProfileInfoWidgetState extends State<RemoteUserProfileInfoWidget> {
  bool _isPrivateAccount = false;
  bool _isLoading = false;
  bool _isApproved = false;
  @override
  void initState() {
    _initUser();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
       if(!widget._isFromProfilePage)
         Padding(
           padding: const EdgeInsets.all(10.0),
           child: Align(
             alignment: Alignment.topRight,
             child: IconButton(
                 style: IconButton.styleFrom(
                     backgroundColor: AppColors.lightGreyColor,
                     shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(99)
                     )
                 ),
                 onPressed: ()=> context.pop(), icon: Icon(Icons.close)),
           ),
         ),

        ProfileInfoWidget(userID: widget._userID),
        if(!widget._isFromProfilePage)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: SizedBox(
              height: 45,
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: StreamBuilder(stream: UserService.getIsFollowingStreamInModel(widget._userID), builder: (ctx, snapshot){
                      if(snapshot.hasData){
                        FollowModel? follow = snapshot.requireData;
                        String text = follow != null ? (follow.isApproved
                            ? 'Following'
                            : 'Request Sent') : 'Follow';
                        if(follow != null){
                          _isApproved = follow.isApproved;
                        }
                        return PrimaryBtn(
                          btnText: text,
                          isPrefix: true,
                          icon: AppIcons.icAddUser,
                          onTap: () => UserService.onFollowTap(remoteUID: widget._userID, userName: widget._userName ?? '', isPrivateAccount: _isPrivateAccount),
                          bgGradient: AppIcons.primaryBgGradient,
                          iconColor: Colors.white,);
                      }

                      return PrimaryBtn(btnText: "Follow",isPrefix: true, icon: AppIcons.icAddUser, onTap: ()=> UserService.onFollowTap(remoteUID: widget._userID, userName: widget._userName ?? '', isPrivateAccount: _isPrivateAccount), bgGradient: AppIcons.primaryBgGradient,);
                    }),
                  ),
                  // Expanded(child: SecondaryGradientBtn(btnText: "Message",isPrefix: true, icon: AppIcons.gradientChatIcon, onTap: (){}, )),
                ],
              ),
            ),
          ),
        _isLoading
            ? LoadingWidget()
            : _buildUserInfoWidget(),

      ],
    );
  }

  void _initUser() async{
    setState(() => _isLoading = true);
    try{
      UserModel? user = await UserService.getUserByID(userID: widget._userID);
      if(user != null){
        _isPrivateAccount = user.visibility == ProfileVisibility.followersOnly;
      }
      _isLoading = false;
    }catch(e){
      debugPrint("Error while getting isPrivateProfile: ${e.toString()}");
    }

    setState(() {});
  }

  Widget _buildUserInfoWidget() {
    bool hideProfile = _isPrivateAccount && !_isApproved && !widget._isFromProfilePage;
    return hideProfile
        ? PrivateAccountWidget()
        : _buildPublicAccountWidget();
  }

  Widget _buildPublicAccountWidget() {
    return Column(
      children: [


        if(!widget._isFromProfilePage && !_isPrivateAccount)
          Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text("Recent Reels", style: AppTextStyles.headingTextStyle3,)),
              ),
              SizedBox(
                height: 200,
                child: FutureBuilder(future: ReelsService.fetchUserReels(
                  userId: widget._userID,
                  limit: 5,
                  onLastDoc: (doc){},
                  onHasMore: (has){}, lastDoc: null,
                ), builder: (ctx, snapshot){

                  if(snapshot.hasData){
                    return ListView.builder(
                        itemCount: snapshot.requireData.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index){
                          ReelModel reel = snapshot.requireData[index];
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(imageUrl: reel.thumbnailUrl ?? AppIcons.icDummyImgUrl, fit: BoxFit.cover,)),
                          );
                        });
                  }else if(snapshot.connectionState == ConnectionState.waiting){
                    return ListView.builder(
                        itemCount: 3,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index){
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: ReelThumbnailShimmerItem(),
                          );
                        });
                  }

                  return SizedBox();
                }),
              ),
            ],
          ),

        if(!widget._isFromProfilePage && !_isPrivateAccount)
          Padding(
            padding: const EdgeInsets.only(bottom: 140.0),
            child: TextButton(onPressed: () {
              context.pop();
              context.push(RouterEnum.remoteUserProfileView.routeName, extra: {
                'userID' : widget._userID,
                'userName' : widget._userName,
                'profilePicture' : widget._profilePicture
              });                  // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> RemoteUserProfilePage(userID: _userID, userName: _userName, profilePicture: _profilePicture,)));
            },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GradientTextWidget(
                      gradient: AppGradients.primaryGradient,
                      text: "View Complete Profile",
                      textStyle: AppTextStyles.buttonTextStyle.copyWith(fontWeight: FontWeight.w700),),
                    Icon(Icons.navigate_next_rounded, color: AppColors.deepPurpleColor, size: 30,)
                  ],
                )),
          ),
      ],
    );
  }
}