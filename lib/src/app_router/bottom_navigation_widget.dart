import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:go_router/go_router.dart';
import '../res/app_gradients.dart';



class BottomNavigationWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          child!,
          Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                    gradient: AppGradients.primaryGradient
                ),
                child: Padding(
                  // padding: const EdgeInsets.only(left: 10.0, bottom: 25,top: 10, right: 10),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBottomNavigationItemWidget(icon: AppIcons.icHome, isSelected: _calculateSelectedIndex(context) == 0, onTap: ()=> _onItemTapped(0, context)),
                      _buildBottomNavigationItemWidget(icon: AppIcons.icSearch, isSelected: _calculateSelectedIndex(context) == 1, onTap: ()=> _onItemTapped(1, context)),

                      Container(
                        width: 50,
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
                            // Show the wheel selector in a modal bottom sheet

                            // Navigator.of(context).push(MaterialPageRoute(builder: (_)=> CreateUploadFeelPage()), );
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
      // body: child,
      // backgroundColor: backgroundColor,
      // bottomNavigationBar: Container(
      //   color: Colors.black,
      //   child: BottomNavigationBar(
      //     key: ValueKey(location),
      //     currentIndex: _calculateSelectedIndex(context),
      //     selectedItemColor: Colors.purple,
      //     unselectedItemColor: Colors.grey,
      //     onTap: (index) => _onItemTapped(index, context),
      //     showSelectedLabels: false,
      //     showUnselectedLabels: false,
      //     selectedFontSize: 0,
      //     unselectedFontSize: 0,
      //     items: [
      //       BottomNavigationBarItem(
      //         label: '',
      //         icon: SvgPicture.asset(AppIcons.icHome),
      //         activeIcon: SvgPicture.asset(AppIcons.icHome),
      //       ),
      //       BottomNavigationBarItem(
      //         label: '',
      //         icon: SvgPicture.asset(AppIcons.icSearch),
      //         activeIcon: SvgPicture.asset(AppIcons.icSearch),
      //       ),
      //       BottomNavigationBarItem(
      //         label: '',
      //         icon: SvgPicture.asset(AppIcons.icUserProfile),
      //         activeIcon: SvgPicture.asset(AppIcons.icUserProfile),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  Widget _buildBottomNavigationItemWidget({required String icon, required bool isSelected, required VoidCallback onTap}) =>
      IconButton(onPressed: onTap, icon: SvgPicture.asset(icon, colorFilter: ColorFilter.mode(isSelected ? Colors.black : Colors.white, BlendMode.srcIn),));

}

int _calculateSelectedIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.toString();

  if (location == RouterEnum.videoFeedView.routeName) {
    return 0;
  }
  if (location == RouterEnum.dashboardView.routeName) {
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
  switch (index) {
    case 0:
      GoRouter.of(context).go(RouterEnum.videoFeedView.routeName);
      break;
    case 1:
      GoRouter.of(context).go(RouterEnum.dashboardView.routeName);
      break;
    case 2:
      GoRouter.of(context).go(RouterEnum.notificationView.routeName);
      break;

    case 3:
      GoRouter.of(context).go(RouterEnum.profileView.routeName);
      break;
  }
}

