import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/main_menu/profile/settings/profile_settings_page.dart';
import 'package:funli_app/src/features/personalization/age_gender_page.dart';
import 'package:funli_app/src/providers/profile_provider.dart';
import 'package:funli_app/src/providers/size_provider.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
import 'package:funli_app/src/widgets/profile_info_widget.dart';
import 'package:provider/provider.dart';

import '../../../res/app_gradients.dart';
import 'widgets/remote_user_bookmark_widget.dart';
import 'widgets/remote_user_reels_widget.dart';

class UserProfilePage extends StatefulWidget{
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with TickerProviderStateMixin{

  late TabController _tabController;
  String userID = FirebaseAuth.instance.currentUser!.uid;
  String? userName;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size  = Provider.of<SizeProvider>(context).size;
    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          height: size.height*0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<ProfileProvider>(builder: (ctx, provider, _){
                if(provider.currentUser != null){
                  userName = provider.currentUser!.userName;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                            child: Row(
                              spacing: 20,
                              children: [

                                AppBackButton(color: Colors.black,),
                                Text(provider.currentUser != null ? provider
                                    .currentUser!.userName : "User not found",
                                  style: AppTextStyles.headingTextStyle3,),

                              ],),
                          )),
                      Expanded(child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(onPressed: () {},
                              icon: SvgPicture.asset(AppIcons.icAnalytics)),
                          IconButton(onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> ProfileSettingsPage(currentUser: provider.currentUser!,)));
                          },
                              icon: SvgPicture.asset(AppIcons.icSettings)),
                        ],))


                    ],
                  ),
                );
              }),
              const SizedBox(height: 20,),
             ProfileInfoWidget(userID: userID),
               Consumer<ProfileProvider>(builder: (ctx, provider, _){
                return TabBar(
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
                    if (index != provider.selectedTab) {
                      provider.onTabChange(index);
                    }
                  },
                  tabs: [
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: SvgPicture.asset(provider.selectedTab == 0 ? AppIcons.icSelectedCategory : AppIcons.icCategory),
                    ),
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: SvgPicture.asset(provider.selectedTab == 1 ? AppIcons.icSelectedBookMark : AppIcons.icBookMark),
                    ),
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: SvgPicture.asset(provider.selectedTab == 1 ? AppIcons.icLikedIcon : AppIcons.icHeartFilledUnSelected),
                    ),
                  ],
                );
              }),
              // Tabs and TabView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    RemoteUserReelsWidget(userID: userID, userName: userName),
                    RemoteUserBookmarkWidget(),
                    SizedBox()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}