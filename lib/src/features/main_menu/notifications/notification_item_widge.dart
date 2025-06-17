import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/models/notification_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';

import '../profile/remote_user_profile.dart';

class NotificationItemWidget extends StatefulWidget{
  final NotificationModel _notification;

  const NotificationItemWidget({super.key, required NotificationModel notification}): _notification = notification;

  @override
  State<NotificationItemWidget> createState() => _NotificationItemWidgetState();
}

class _NotificationItemWidgetState extends State<NotificationItemWidget> {
  UserModel? user;
  bool _isLoadingUser = false;
  
  @override
  void initState() {
    _initUser();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        String? userName = user?.userName;
        String? userID = user?.userID;
        showModalBottomSheet(
            isScrollControlled: true,
            context: context, builder: (ctx){
          return FractionallySizedBox(
              heightFactor: 0.75,
              child: SingleChildScrollView(child: RemoteUserProfileInfoWidget(userName: userName, userID: userID!,)));
        });
      },
      contentPadding: EdgeInsets.only(right: 10),
      leading: ProfilePictureWidget(
          profilePicture: (_isLoadingUser || user == null) 
              ? AppIcons.icDummyImgUrl : user!.profilePicture),
      title: Text((_isLoadingUser || user == null) ?  '' : user!.userName, style: AppTextStyles.smallTextStyle.copyWith(fontWeight: FontWeight.w700),),
      subtitle: Text(widget._notification.notificationDescription, style: AppTextStyles.captionTextStyle.copyWith(color: AppColors.icCommentGreyColor),),
      trailing: widget._notification.notificationType ==
          NotificationType.like || widget._notification.notificationType == NotificationType.comment
          ? _buildThumbnailWidget()
          : widget._notification.notificationType == NotificationType.follow
          ? _buildFollowFollowingWidget()
          : const SizedBox(),
    );
  }

  void _initUser() async{
    setState(() => _isLoadingUser = true);
    user = await UserService.getUserByID(userID: widget._notification.userID);
    setState(()=>  _isLoadingUser = false);
  }

  Widget _buildThumbnailWidget() {
    return FutureBuilder(future: ReelsService.getReelByID(widget._notification.reelID!), builder: (ctx, snapshot){
      if(snapshot.hasData && snapshot.requireData != null){
        return SizedBox(
          height: 60,
          width: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(imageUrl: snapshot.requireData!.thumbnailUrl ?? AppIcons.icDummyImgUrl, fit: BoxFit.cover,),
          ),
        );
      }

      return SizedBox();
    });
  }

  Widget _buildFollowFollowingWidget() {
    return StreamBuilder(stream: UserService.getIsFollowingStream(widget._notification.userID), builder: (ctx, snapshot){
      if(snapshot.hasData && !snapshot.requireData){
        return SizedBox(
          width: 120,
          height: 38,
          child: PrimaryBtn(btnText: "Follow Back", icon: '', onTap: (){
            UserService.onFollowTap(remoteUID: widget._notification.userID, userName: user != null ? user!.userName : '');
          }, bgGradient: AppIcons.primaryBgGradient, textStyle: AppTextStyles.smallTextStyle,),
        );
      }

      return SizedBox();
    });
  }
}