import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/models/notification_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';

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
      contentPadding: EdgeInsets.only(right: 10),
      leading: ProfilePictureWidget(
          profilePicture: (_isLoadingUser || user == null) 
              ? AppIcons.icDummyImgUrl : user!.profilePicture),
      title: Text((_isLoadingUser || user == null) ?  '' : user!.userName, style: AppTextStyles.smallTextStyle.copyWith(fontWeight: FontWeight.w700),),
      subtitle: Text(widget._notification.notificationDescription, style: AppTextStyles.captionTextStyle.copyWith(color: AppColors.icCommentGreyColor),),
      trailing: widget._notification.notificationType == NotificationType.like || widget._notification.notificationType == NotificationType.comment ? _buildThumbnailWidget() : _buildFollowFollowingWidget(),
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
    return SizedBox();
  }
}