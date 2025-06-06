import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:funli_app/src/features/main_menu/notifications/notification_page.dart';
import 'package:funli_app/src/features/main_menu/reels_home_page/reels_page.dart';
import 'package:funli_app/src/features/main_menu/discover_page/discover_page.dart';
import 'package:funli_app/src/features/main_menu/profile/user_profile_page.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:provider/provider.dart';
import '../../notification_service/notification_service.dart';
import '../../providers/size_provider.dart';
import '../../providers/tab_change_provider.dart';
import '../../res/app_icons.dart';
import '../upload_feel/create_upload_feel_page.dart';

class MainMenuPage extends StatefulWidget{
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {

  final List<Widget> _pages = [
    SizedBox.expand(child: const ReelsPage()),
    SizedBox.expand(child: const DiscoverPage()),
    SizedBox.expand(child: const NotificationPage()),
    SizedBox.expand(child: const UserProfilePage()),
  ];
  @override
  void initState() {
    _initNotificationService();
    _initSize();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<MainMenuTabChangeProvider>(builder: (ctx, provider, _){
      return Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            IndexedStack(
              index: provider.currentIndex,
              children: _pages,
            ),
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
                    padding: const EdgeInsets.only(left: 10.0, bottom: 25,top: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBottomNavigationItemWidget(icon: AppIcons.icHome, isSelected: provider.currentIndex == 0, onTap: ()=> _onNavigationItemTap(0, provider)),
                        _buildBottomNavigationItemWidget(icon: AppIcons.icSearch, isSelected: provider.currentIndex == 1, onTap: ()=> _onNavigationItemTap(1, provider)),

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

                              Navigator.of(context).push(MaterialPageRoute(builder: (_)=> CreateUploadFeelPage()), );
                            }, icon: Icon(Icons.add, color: Colors.white,)),
                          ),
                        ),


                        _buildBottomNavigationItemWidget(icon: AppIcons.icNotification, isSelected: provider.currentIndex == 2, onTap: ()=> _onNavigationItemTap(2, provider)),
                        _buildBottomNavigationItemWidget(icon: AppIcons.icUserProfile, isSelected: provider.currentIndex == 3, onTap: ()=> _onNavigationItemTap(3, provider)),

                      ],
                    ),
                  ),
                )),
          ],
        ),
      );
    },
    );
  }

  void _onNavigationItemTap(int index, MainMenuTabChangeProvider provider){
    provider.onTabChange(index);
  }

  Widget _buildBottomNavigationItemWidget({required String icon, required bool isSelected, required VoidCallback onTap}) =>
      IconButton(onPressed: onTap, icon: SvgPicture.asset(icon, colorFilter: ColorFilter.mode(isSelected ? Colors.black : Colors.white, BlendMode.srcIn),));

  void _initNotificationService()async{
    //Get notification permission then
    await FirebaseNotificationsService.requestPermissions().then((value) {});
    try{
      await FirebaseNotificationsService.initializeLocalNotifications();
      await FirebaseNotificationsService.initializeFirebaseMessaging().then((value) {
        FirebaseNotificationsService.startNotificationListeners();
      });
      FirebaseNotificationsService.startNotificationClickListeners();
    }catch(e){
      debugPrint("Exception while notification configuration: ${e.toString()}");
    }
  }

  void _initSize() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      Size size = MediaQuery.of(context).size;
      context.read<SizeProvider>().setSize(size);
    });
  }
}