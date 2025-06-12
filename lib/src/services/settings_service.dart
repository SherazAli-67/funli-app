import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class SettingsService {
  static final CollectionReference _userColRef = FirebaseFirestore.instance.collection(FirebaseConstants.userCollection);
  static Stream<bool> isPrivateAccount(String userID){
   return _userColRef.doc(userID).snapshots().map((snapshot){
      final map = snapshot.data() as Map<String, dynamic>;
      UserModel user = UserModel.fromMap(map);
      return user.visibility.value == 'followersOnly';
    });
  }

  static Stream<ProfileVisibility> getProfileVisibility(){
    String userID = FirebaseAuth.instance.currentUser!.uid;
    return _userColRef.doc(userID).snapshots().map((snapshot){
      final map = snapshot.data() as Map<String, dynamic>;
      UserModel user = UserModel.fromMap(map);
      return user.visibility;
    });
  }

  static Future<void> setAccountVisibility({required ProfileVisibility visibility}) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

   await _userColRef.doc(userID).update({
      'visibility' : visibility.value
    });
  }

  static Stream<bool> getSuggestAccountToOthers(){
    String userID = FirebaseAuth.instance.currentUser!.uid;
    return _userColRef.doc(userID).snapshots().map((snapshot){
      final map = snapshot.data() as Map<String, dynamic>;
      bool isPrivateAccount = map['suggestAccountToOthers'] ?? false;
      return isPrivateAccount;
    });
  }

  static Future<void> setSuggestAccountToOthers({required bool isSuggest}) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    await _userColRef.doc(userID).update({
      'suggestAccountToOthers' : isSuggest
    });
  }

  static Stream<bool> getRememberMe(){
    String userID = FirebaseAuth.instance.currentUser!.uid;
    return _userColRef.doc(userID).snapshots().map((snapshot){
      final map = snapshot.data() as Map<String, dynamic>;
      bool rememberMe = map['rememberMe'] ?? true;
      return rememberMe;
    });
  }

  static Future<void> setRememberMe({required bool rememberMe}) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    await _userColRef.doc(userID).update({
      'rememberMe' : rememberMe
    });
  }

  static Stream<bool> getShowAdultContent(){
    String userID = FirebaseAuth.instance.currentUser!.uid;
    return _userColRef.doc(userID).snapshots().map((snapshot){
      final map = snapshot.data() as Map<String, dynamic>;
      bool rememberMe = map['showAdultContent'] ?? false;
      return rememberMe;
    });
  }

  static Future<void> setShowAdultContent({required bool showAdultContent}) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    await _userColRef.doc(userID).update({
      'showAdultContent' : showAdultContent
    });
  }
}