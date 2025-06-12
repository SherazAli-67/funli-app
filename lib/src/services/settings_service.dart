import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class SettingsService {
  static final CollectionReference _userColRef = FirebaseFirestore.instance.collection(FirebaseConstants.userCollection);
  static Stream<bool> isPrivateAccount(String userID){
   return _userColRef.doc(userID).snapshots().map((snapshot){
      final map = snapshot.data() as Map<String, dynamic>;
      bool isPrivateAccount = map['isPrivate'] ?? false;
      return isPrivateAccount;
    });
  }

  static Future<void> setAccountVisibility({required bool isPrivate}) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

   await _userColRef.doc(userID).update({
      'isPrivate' : isPrivate
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
}