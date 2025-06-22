import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/providers/profile_provider.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/profile_info_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../res/app_gradients.dart';
import 'widgets/remote_user_bookmark_widget.dart';
import 'widgets/remote_user_reels_widget.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with TickerProviderStateMixin {
  late TabController _tabController;
  String userID = FirebaseAuth.instance.currentUser!.uid;
  String? userName;
  String? profilePicture;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      if (provider.currentUser != null && provider.userName.isNotEmpty) {
        provider.initUserProfile();
      }
      _tabController.addListener(() {
        provider.onTabChange(_tabController.index);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          provider.currentUser?.userName ?? "",
          style: AppTextStyles.headingTextStyle3,
        ),
        actions: [
          IconButton(
            onPressed: () =>
                context.push(
                    RouterEnum.profileAnalyticsView.routeName),
            icon: SvgPicture.asset(AppIcons.icAnalytics),
          ),
          IconButton(
            onPressed: () =>
                context.push(
                    RouterEnum.profileSettingsView.routeName),
            icon: SvgPicture.asset(AppIcons.icSettings),
          ),
        ],
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) =>
            [

              SliverToBoxAdapter(
                child: ProfileInfoWidget(userID: userID),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorWeight: 4.0,
                    labelPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0, bottom: 0),

                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: ShapeDecoration(
                      shape: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      gradient: AppGradients.primaryGradient,
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    onTap: (index)=> provider.onTabChange(index),
                    tabs: [
                      Container(
                        height: 50,

                        alignment: Alignment.center,
                        color: Colors.white,
                        child: SvgPicture.asset(
                          provider.selectedTab == 0 ? AppIcons.icSelectedCategory : AppIcons.icCategory,
                        ),
                      ),
                      Container(
                        height: 50,
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: SvgPicture.asset(
                          provider.selectedTab == 1 ? AppIcons.icSelectedBookMark : AppIcons.icBookMark,
                        ),
                      ),
                      Container(
                        height: 50,
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: SvgPicture.asset(
                          provider.selectedTab == 2 ? AppIcons.icLikedIcon : AppIcons.icHeartFilledUnSelected,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                RemoteUserReelsWidget(userID: userID, userName: userName, profilePicture: profilePicture),
                BookmarkWidget(userID: userID),
                SizedBox(), // Placeholder
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      height: tabBar.preferredSize.height,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
