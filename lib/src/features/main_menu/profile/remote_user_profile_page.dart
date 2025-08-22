import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/main_menu/profile/remote_user_profile.dart';
import 'package:funli_app/src/features/main_menu/profile/widgets/remote_user_bookmark_widget.dart';
import 'package:funli_app/src/features/main_menu/profile/widgets/remote_user_reels_widget.dart';
import 'package:funli_app/src/models/follow_model.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/private_account_widget.dart';

import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../widgets/primary_btn.dart';

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
  bool _hideProfile = false;
  bool _isLoading = false;

  bool _isPrivateAccount = false;
  @override
  void initState() {

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != selectedTabIndex) {
        setState(() => selectedTabIndex = _tabController.index);
      }
    });
    _initUser();
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
      body:  _isLoading ? LoadingWidget() : _hideProfile
          ? _buildPrivateAccountProfileWidget()
          : DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: RemoteUserProfileInfoWidget(
                userID: widget._userID,
                userName: widget._userName,
                profilePicture: widget._profilePicture,
                isFromProfilePage: true,
              ),),

            SliverToBoxAdapter(
              child: Padding(
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
              ),),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorWeight: 4.0,
                  labelPadding: EdgeInsets.only(
                      left: 0.0, right: 0.0, top: 0, bottom: 0),

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
                        selectedTabIndex == 0
                            ? AppIcons.icSelectedCategory
                            : AppIcons.icCategory,
                      ),
                    ),
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: SvgPicture.asset(
                        selectedTabIndex == 1
                            ? AppIcons.icSelectedBookMark
                            : AppIcons.icBookMark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: _isLoading
              ? LoadingWidget()
              : _buildUserInfoWidget(),
        ),
      ),
    );
  }

  void _initUser() async{
    setState(() => _isLoading = true);
    bool isApproved = false;
    try{


      UserModel? user = await UserService.getUserByID(userID: widget._userID);
      if(user != null){
        debugPrint('Visibility: ${user.visibility.name}');
        _isPrivateAccount = user.visibility == ProfileVisibility.followersOnly;
      }
      _isLoading = false;
    }catch(e){
      debugPrint("Error while getting isPrivateProfile: ${e.toString()}");
    }

    try{
      FollowModel? follow = await UserService.getIsFollowing(widget._userID);
      debugPrint("Follow model: ${follow?.toMap()}");
      if(follow != null){
        isApproved = follow.isApproved;
      }
    }catch(e){
      debugPrint("Error while getting getIsFollowing: ${e.toString()}");
    }

    _hideProfile =  _isPrivateAccount && !isApproved;
    setState(() {});
  }

  Widget _buildUserInfoWidget() {

    return  TabBarView(
      controller: _tabController,
      children: [
        RemoteUserReelsWidget(
          userID: widget._userID,
          userName: widget._userName,
        ),
        BookmarkWidget(userID: widget._userID),
      ],
    );
  }

  _buildPrivateAccountProfileWidget() {
    return Column(
      spacing: 20,
      children: [
        RemoteUserProfileInfoWidget(
          userID: widget._userID,
          userName: widget._userName,
          profilePicture: widget._profilePicture,
          isFromProfilePage: true,
        ),
        PrivateAccountWidget()
      ],
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