import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/services/user_service.dart';

class ProfileProvider extends ChangeNotifier{
  final String _currentUID = FirebaseAuth.instance.currentUser!.uid;
  UserModel? _currentUser;
  int _selectedTab = 0;

  UserModel? get currentUser => _currentUser;
  String get currentUID => _currentUID;
  int get selectedTab => _selectedTab;
  ProfileProvider(){
    _initUserProfile();
  }

  void _initUserProfile() async{
    _currentUser = await UserService.getUserByID(userID: _currentUID);
    debugPrint("currnet username: ${currentUser?.userName}");
    notifyListeners();
  }

  void onTabChange(int index){
    _selectedTab = index;
    notifyListeners();
  }
}