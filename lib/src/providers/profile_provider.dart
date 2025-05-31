import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/services/user_service.dart';

class ProfileProvider extends ChangeNotifier{
  final String _currentUID = FirebaseAuth.instance.currentUser!.uid;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  String get currentUID => _currentUID;
  ProfileProvider(){
    _initUserProfile();
  }

  void _initUserProfile() async{
    _currentUser = await UserService.getUserByID(userID: _currentUID);
    debugPrint("currnet username: ${currentUser?.userName}");
    notifyListeners();
  }

}