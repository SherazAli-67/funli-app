import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:go_router/go_router.dart';
import '../notification_service/notification_service.dart';
import '../providers/size_provider.dart';
import '../res/app_gradients.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();



class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({
    super.key,
    this.child,
    required this.location,
    this.backgroundColor,
  });

  final Widget? child;
  final String location;
  final Color? backgroundColor;

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {

  @override
  void initState() {

    _initNotificationService();
    _initSize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = _calculateSelectedIndex(context);
    return Scaffold(
      key: scaffoldKey,
      body: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            widget.child!,
            Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                      gradient: AppGradients.bottomNavGradient
                    // color: Colors.black
                  ),
                  child: Padding(
                    // padding: const EdgeInsets.only(left: 10.0, bottom: 25,top: 10, right: 10),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBottomNavigationItemWidget(icon: selectedIndex == 0 ? AppIcons.icSelectedHome : AppIcons.icHome, isSelected: _calculateSelectedIndex(context) == 0, onTap: ()=> _onItemTapped(0, context)),
                        _buildBottomNavigationItemWidget(icon: AppIcons.icSearch, isSelected: _calculateSelectedIndex(context) == 1, onTap: ()=> _onItemTapped(1, context)),

                        Container(
                          width: 45,
                          height: 65,
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              gradient: AppGradients.uploadBtnGradient,
                              borderRadius: BorderRadius.circular(35)
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(35)
                            ),
                            child: IconButton(onPressed: ()async{
                              // context.read<UpdatedFeedCubit>().setShouldPauseVideo(true);
                              context.go(RouterEnum.createUploadReelView.routeName);
                            }, icon: Icon(Icons.add, color: Colors.white,)),
                          ),
                        ),


                        _buildBottomNavigationItemWidget(icon: AppIcons.icNotification, isSelected: _calculateSelectedIndex(context)== 2, onTap: ()=> _onItemTapped(2, context)),
                        _buildBottomNavigationItemWidget(icon: AppIcons.icUserProfile, isSelected: _calculateSelectedIndex(context) == 3, onTap: ()=> _onItemTapped(3, context)),

                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationItemWidget({required String icon, required bool isSelected, required VoidCallback onTap}) =>
      IconButton(onPressed: onTap, icon: SvgPicture.asset(icon,));

  void _initNotificationService()async{
    //Get notification permission then
    await FirebaseNotificationsService.requestPermissions().then((value) {});
    try{
      await FirebaseNotificationsService.initializeLocalNotifications();
      await FirebaseNotificationsService.initializeFirebaseMessaging().then((value) {
        FirebaseNotificationsService.startNotificationListeners();
      });
      FirebaseNotificationsService.startNotificationClickListeners();
    }catch(e){
      debugPrint("Exception while notification configuration: ${e.toString()}");
    }
  }

  void _initSize() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      Size size = MediaQuery.of(context).size;
      context.read<SizeProvider>().setSize(size);
    });
  }
}

int _calculateSelectedIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.toString();

  if (location == RouterEnum.videoFeedView.routeName) {
    return 0;
  }
  if (location == RouterEnum.discoverView.routeName) {
    return 1;
  }
  if (location == RouterEnum.notificationView.routeName) {
    return 2;
  }
  if (location == RouterEnum.profileView.routeName) {
    return 3;
  }
  return 0;
}

void _onItemTapped(int index, BuildContext context) {
  // Get the current location
  final String currentLocation = GoRouterState.of(context).uri.toString();
  
  /*// First set the pause state based on which tab is selected
  if (index == 0) { // VideoFeedView is at index 0
    context.read<UpdatedFeedCubit>().setShouldPauseVideo(false);
  } else {
    context.read<UpdatedFeedCubit>().setShouldPauseVideo(true);
  }*/
  
  // Check if user is already on VideoFeedView and taps home icon again
  if (index == 0 && currentLocation == RouterEnum.videoFeedView.routeName) {
    // User is already on VideoFeedView and tapped home icon again
    // Refresh the feed by calling loadVideos

    // context.read<UpdatedFeedCubit>().loadVideos(isRefresh: true);
    return; // Don't navigate since we're already on the correct page
  }
  
  // Then navigate to the selected tab
  switch (index) {
    case 0:
      GoRouter.of(context).go(RouterEnum.videoFeedView.routeName);
      break;
    case 1:
      GoRouter.of(context).go(RouterEnum.discoverView.routeName);
      break;
    case 2:
      GoRouter.of(context).go(RouterEnum.notificationView.routeName);
      break;
    case 3:
      GoRouter.of(context).go(RouterEnum.profileView.routeName);
      break;
  }
}
