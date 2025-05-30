import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/main_menu/profile/remote_user_profile.dart';
import 'package:funli_app/src/features/main_menu/profile/widgets/remote_user_bookmark_widget.dart';
import 'package:funli_app/src/features/main_menu/profile/widgets/remote_user_reels_widget.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';

class RemoteUserProfilePage extends StatefulWidget{
  const RemoteUserProfilePage({
    super.key,
    required String userID,
    String? userName,
    String? profilePicture,
  }): _userID = userID, _userName = userName, _profilePicture = profilePicture;

  final String _userID;
  final String? _userName;
  final String? _profilePicture;

  @override
  State<RemoteUserProfilePage> createState() => _RemoteUserProfilePageState();
}

class _RemoteUserProfilePageState extends State<RemoteUserProfilePage> with TickerProviderStateMixin{
  late TabController _tabController;
  int selectedTabIndex = 0;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black,)),
        title: Text(widget._userName ?? '', style: AppTextStyles.headingTextStyle3,),
        centerTitle: false,
        actions: [
          PopupMenuButton(
              padding: EdgeInsets.zero,
              onSelected: (val){},
              position: PopupMenuPosition.under,
              icon: Icon(Icons.more_vert_rounded),
              color: Colors.white,
              itemBuilder: (_){
            return [
              PopupMenuItem(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  value: 1,
                  child: Row(
                    spacing: 12,
                    children: [
                    SvgPicture.asset(AppIcons.icReportUser),
                    Text("Report user", style: AppTextStyles.smallTextStyle,)
              ],)),
              PopupMenuItem(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  value: 1,
                  child: Row(
                    spacing: 12,
                    children: [
                      SvgPicture.asset(AppIcons.icBlockUser),
                      Text("Block user", style: AppTextStyles.smallTextStyle,)
                    ],))
            ];
          })
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height * 0.9,
            child: Column(
              spacing: 20,
              children: [
                // User profile info
                RemoteUserProfileInfoWidget(
                  userID: widget._userID,
                  userName: widget._userName,
                  profilePicture: widget._profilePicture,
                  isFromProfilePage: true,
                ),
          
                TabBar(
                  controller: _tabController,
                  dividerHeight: 1,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 4.0,
                  labelPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                  unselectedLabelColor: Colors.black,
                  labelColor: Colors.black,
                  labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  indicator: ShapeDecoration(
                    shape: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                    ),
                    gradient: AppGradients.primaryGradient,
                  ),
                  onTap: (index) {
                    if (index != selectedTabIndex) {
                      setState(() => selectedTabIndex = index);
                    }
                  },
                  tabs: [
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: SvgPicture.asset(selectedTabIndex == 0 ? AppIcons.icSelectedCategory : AppIcons.icCategory),
                    ),
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: SvgPicture.asset(selectedTabIndex == 1 ? AppIcons.icSelectedBookMark : AppIcons.icBookMark),
                    ),
                  ],
                ),
                // Tabs and TabView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      RemoteUserReelsWidget(userID: widget._userID, userName: widget._userName,),
                      RemoteUserBookmarkWidget()
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      )
    );
  }
}
