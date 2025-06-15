import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:go_router/go_router.dart';
import '../res/app_gradients.dart';

/*
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
      body: child,
      backgroundColor: backgroundColor,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient
        ),
        child: BottomNavigationBar(
          key: ValueKey(location),
          currentIndex: _calculateSelectedIndex(context),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          onTap: (index) => _onItemTapped(index, context),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          items: [
             BottomNavigationBarItem(
              label: '',
              icon: SvgPicture.asset(AppIcons.icHome),
              activeIcon: SvgPicture.asset(AppIcons.icHome),
            ),
             BottomNavigationBarItem(
              label: '',
              icon: SvgPicture.asset(AppIcons.icSearch),
              activeIcon: SvgPicture.asset(AppIcons.icHome),
            ),
             BottomNavigationBarItem(
              label: '',
              icon: SvgPicture.asset(AppIcons.icNotification),
              activeIcon: SvgPicture.asset(AppIcons.icNotification),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: SvgPicture.asset(AppIcons.icUserProfile),
              activeIcon: SvgPicture.asset(AppIcons.icUserProfile),
            ),
          ],
        ),
      ),
    );
  }
}

int _calculateSelectedIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.toString();

  if (location == RouterEnum.homeView.routeName) {
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
  switch (index) {
    case 0:
      GoRouter.of(context).go(RouterEnum.homeView.routeName);
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
*/


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
      body: child,
      backgroundColor: backgroundColor,
      bottomNavigationBar: Container(
        color: Colors.black,
        child: BottomNavigationBar(
          key: ValueKey(location),
          currentIndex: _calculateSelectedIndex(context),
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          onTap: (index) => _onItemTapped(index, context),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          items: [
            BottomNavigationBarItem(
              label: '',
              icon: SvgPicture.asset(AppIcons.icHome),
              activeIcon: SvgPicture.asset(AppIcons.icHome),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: SvgPicture.asset(AppIcons.icSearch),
              activeIcon: SvgPicture.asset(AppIcons.icSearch),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: SvgPicture.asset(AppIcons.icUserProfile),
              activeIcon: SvgPicture.asset(AppIcons.icUserProfile),
            ),
          ],
        ),
      ),
    );
  }
}

int _calculateSelectedIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.toString();

  if (location == RouterEnum.videoFeedView.routeName) {
    return 0;
  }
  if (location == RouterEnum.dashboardView.routeName) {
    return 1;
  }
  if (location == RouterEnum.profileView.routeName) {
    return 2;
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
      GoRouter.of(context).go(RouterEnum.profileView.routeName);
      break;
  }
}

