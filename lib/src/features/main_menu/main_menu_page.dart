import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../res/app_colors.dart';
import '../../res/app_icons.dart';
import '../../res/app_textstyles.dart';

class MainMenuPage extends StatelessWidget{
  final StatefulNavigationShell navigationShell;
  const MainMenuPage({super.key, required this.navigationShell});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SalomonBottomBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index)=> navigationShell.goBranch(index),
          items: [
            _buildNavigationItemWidget(icon: AppIcons.icHome, label: "Home", index: 0),
            _buildNavigationItemWidget(icon: AppIcons.icSearch, label: "Discover", index: 1),
            _buildNavigationItemWidget(icon: AppIcons.icNotification, label: "Notifications", index: 2),
            _buildNavigationItemWidget(icon: AppIcons.icUserProfile, label: "Profile", index: 3),
          ]),

     /* BottomNavigationBar(
        backgroundColor: Colors.white,
          selectedLabelStyle: AppTextStyles.smallTextStyle,
          selectedItemColor: Colors.white,
          unselectedLabelStyle: AppTextStyles.smallTextStyle,
          onTap: (int index)=>navigationShell.goBranch(index),
          unselectedItemColor: AppColors.greyTextColor,
          currentIndex: navigationShell.currentIndex,
          type: .fixed,
          items: [
            _buildBottomNavigationItemWidget(icon: AppIcons.icHome, label: "Home", index: 0),
            _buildBottomNavigationItemWidget(icon: AppIcons.icSearch, label: "Discover", index: 1),
            _buildBottomNavigationItemWidget(icon: AppIcons.icNotification, label: "Notifications", index: 2),
            _buildBottomNavigationItemWidget(icon: AppIcons.icUserProfile, label: "Profile", index: 3),

          ]),*/
      body: SafeArea(child: navigationShell),
    );
  }

/*  BottomNavigationBarItem _buildBottomNavigationItemWidget({required String icon, required String label, required int index}) =>
      BottomNavigationBarItem(
        icon: navigationShell.currentIndex == index
            ? Container(
          decoration: BoxDecoration(
            shape: .circle,
            color: AppColors.colorBlack
          ),
          padding: .all(8),
          child: SvgPicture.asset(icon,  colorFilter: .mode(Colors.white, .srcIn),),)
            : SvgPicture.asset(icon, colorFilter: .mode(AppColors.colorBlack, .srcIn),),
        label: '',);*/
  SalomonBottomBarItem _buildNavigationItemWidget({required String icon, required String label, required int index}){
    bool isSelected = navigationShell.currentIndex == index;
    return  SalomonBottomBarItem(
      icon: SvgPicture.asset(icon, colorFilter: .mode(isSelected ? AppColors.primaryColor : AppColors.colorBlack, .srcIn),),
      title: Text(label, style: AppTextStyles.smallTextStyle.copyWith(color: isSelected ? AppColors.primaryColor : AppColors.colorBlack),),
      selectedColor: AppColors.primaryColor
    );
  }
}