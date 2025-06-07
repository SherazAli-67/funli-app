import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/notification_model.dart';
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

  static Future<void> sendNotificationToUser({
    required String receiverID,
    required String description,
    String? reelID,
    required NotificationType notificationType,
  }) async {

    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    String notificationID = DateTime.now().microsecondsSinceEpoch.toString();
    Timestamp timestamp = Timestamp.now();

    //Notification is always user name
    NotificationModel notification = NotificationModel(
        notificationID: notificationID,
        notificationDescription: description,
        userID: currentUID,
        reelID: reelID,
        notificationType: notificationType,
        timestamp: timestamp);

    try{
      await _userColRef.doc(receiverID).collection(
          FirebaseConstants.notificationsCollections)
          .doc(notificationID).set(
          notification.toMap());
      debugPrint("Notification sent to $receiverID");
    }catch(e){
      debugPrint("Failed to add notification to user: ${e.toString()}");
    }

  }
}