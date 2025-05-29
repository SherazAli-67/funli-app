import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/main_menu/profile/remote_user_profile.dart';
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

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    _tabController = TabController(length: 2, vsync: this);
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
        child: Column(
          children: [
            RemoteUserProfileInfoWidget(userID: widget._userID, userName: widget._userName, profilePicture: widget._profilePicture, isFromProfilePage: true,),
            Expanded(child: Column(
              children: [
                TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    dividerHeight: 0,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.all(0.0),
                    indicatorWeight: 4.0,
                    labelPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                    unselectedLabelColor: Colors.black,
                    padding: EdgeInsets.all(3),
                    labelColor: Colors.black,
                    labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                    unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),

                    tabs: [
                      Tab(
                        icon: SvgPicture.asset(AppIcons.icCategory)
                      ),
                      Tab(
                          icon: SvgPicture.asset(AppIcons.icBookMark)
                      ),

                    ])
              ],
            ))
          ],
        ),
      )
    );
  }
}