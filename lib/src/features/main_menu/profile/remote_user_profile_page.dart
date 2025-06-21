import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/main_menu/profile/remote_user_profile.dart';
import 'package:funli_app/src/features/main_menu/profile/widgets/remote_user_bookmark_widget.dart';
import 'package:funli_app/src/features/main_menu/profile/widgets/remote_user_reels_widget.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';

class RemoteUserProfilePage extends StatefulWidget {
  const RemoteUserProfilePage({
    super.key,
    required String userID,
    String? userName,
    String? profilePicture,
  })  : _userID = userID,
        _userName = userName,
        _profilePicture = profilePicture;

  final String _userID;
  final String? _userName;
  final String? _profilePicture;

  @override
  State<RemoteUserProfilePage> createState() => _RemoteUserProfilePageState();
}

class _RemoteUserProfilePageState extends State<RemoteUserProfilePage> with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedTabIndex = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != selectedTabIndex) {
        setState(() => selectedTabIndex = _tabController.index);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        ),
        title: Text(widget._userName ?? '', style: AppTextStyles.headingTextStyle3),
        centerTitle: false,
        actions: [
          PopupMenuButton(
            padding: EdgeInsets.zero,
            onSelected: (val) {},
            position: PopupMenuPosition.under,
            icon: Icon(Icons.more_vert_rounded),
            color: Colors.white,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    SvgPicture.asset(AppIcons.icReportUser),
                    SizedBox(width: 10),
                    Text("Report user", style: AppTextStyles.smallTextStyle),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    SvgPicture.asset(AppIcons.icBlockUser),
                    SizedBox(width: 10),
                    Text("Block user", style: AppTextStyles.smallTextStyle),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: RemoteUserProfileInfoWidget(
                userID: widget._userID,
                userName: widget._userName,
                profilePicture: widget._profilePicture,
                isFromProfilePage: true,
              ),
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
                  onTap: (index) {
                    setState(() => selectedTabIndex = index);
                  },
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    Container(
                      height: 50,

                      alignment: Alignment.center,
                      color: Colors.white,
                      child: SvgPicture.asset(
                        selectedTabIndex == 0 ? AppIcons.icSelectedCategory : AppIcons.icCategory,
                      ),
                    ),
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: SvgPicture.asset(
                        selectedTabIndex == 1 ? AppIcons.icSelectedBookMark : AppIcons.icBookMark,
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
              RemoteUserReelsWidget(
                userID: widget._userID,
                userName: widget._userName,
              ),
              BookmarkWidget(userID: widget._userID),
            ],
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
      alignment: Alignment.center,
      child: SizedBox(
        height: tabBar.preferredSize.height,
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}