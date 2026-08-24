import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
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
  /*    bottomNavigationBar: SalomonBottomBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index)=> navigationShell.goBranch(index),
          items: [
            _buildNavigationItemWidget(icon: AppIcons.icHome, label: "Home", index: 0),
            _buildNavigationItemWidget(icon: AppIcons.icSearch, label: "Discover", index: 1),
            _buildNavigationItemWidget(icon: AppIcons.icNotification, label: "Notifications", index: 2),
            _buildNavigationItemWidget(icon: AppIcons.icUserProfile, label: "Profile", index: 3),
          ]),*/

      bottomNavigationBar: Container(
        height: 85,
        padding: const .symmetric(horizontal: 30,),
        decoration:  BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color:  Color(0xFFEAE7D8).withValues(alpha: 0.6),
                offset: const Offset(0, -2),
                blurRadius: 20,
                spreadRadius: 0,
              )
            ],
            border: Border.fromBorderSide(BorderSide(color: AppColors.greyColor))
        ),

        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              _buildNavigationBarItemWidget(icon: AppIcons.icHome, label: 'Today', index: 0),
              _buildNavigationBarItemWidget(icon: AppIcons.icSearch,  label: 'Browse', index: 1),
              GestureDetector(
                  onTap: ()=> context.push(RouterEnum.createUploadReelView.routeName),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: .circle,
                      color: AppColors.primaryColor,
                    ),
                    padding: .all(8),
                    child:  Icon(Icons.add, size: 24, color: Colors.white,),
                  )
              ),
              _buildNavigationBarItemWidget(icon:  AppIcons.icNotification, label: 'Notifications', index: 2),
              _buildNavigationBarItemWidget(icon:  AppIcons.icUserProfile,  label: 'Profile', index: 3),

            ],
          ),
        ),
      ),
      body: SafeArea(child: navigationShell),
    );
  }

  Widget _buildNavigationBarItemWidget({required int index, required String icon, required String label}) {
    bool isSelected = navigationShell.currentIndex == index;
    return SizedBox(
      height: 36,
      width: 36,
      child: GestureDetector(
        onTap: () => navigationShell.goBranch(index),
        child: Column(
          mainAxisSize: .min,
          children: [
            // navigationShell.currentIndex == index ?
            Container(decoration: BoxDecoration(
              color: isSelected ? AppColors.colorBlack : Colors.white,
              shape: .circle
            ),
              padding: .all(5),
              child: _buildIconWidget(icon: icon, color: isSelected ? Colors.white : AppColors.colorBlack)
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIconWidget({required String icon, required Color color}){
    return SvgPicture.asset(
      icon,
      height: 24,
      width: 24,
      colorFilter: .mode(color, .srcIn),
    );
  }
}