import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/services/user_service.dart';

class ProfileProvider extends ChangeNotifier{
  bool _isProfileLoading = false;
  final String _currentUID = FirebaseAuth.instance.currentUser!.uid;
  UserModel? _currentUser;
  int _selectedTab = 0;

  UserModel? get currentUser => _currentUser;
  String get currentUID => _currentUID;
  bool get isProfileLoading => _isProfileLoading;

  int get selectedTab => _selectedTab;
  ProfileProvider(){
    initUserProfile();
  }

  void initUserProfile() async{
    debugPrint("Initializing the profile");
    _isProfileLoading = true;
    notifyListeners();
    _currentUser = await UserService.getUserByID(userID: _currentUID);
    debugPrint("current username: ${currentUser?.userName}");
    _isProfileLoading = false;
    notifyListeners();
  }

  void onTabChange(int index){
    _selectedTab = index;
    notifyListeners();
  }
}