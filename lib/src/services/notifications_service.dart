import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class NotificationsService {
  static final _userColRef = FirebaseFirestore.instance.collection(FirebaseConstants.userCollection);

  static Future<int> getUnreadNotifications()async{
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    int result = 0;
    try{
       final query = await _userColRef.doc(currentUID).collection(
          FirebaseConstants.notificationsCollections).where(
          'isRead', isEqualTo: false).count().get();
      result =  query.count ?? 0;
    }catch(e){
      debugPrint("Exception while getting notifications: ${e.toString()}");
    }

    return result;
  }
}