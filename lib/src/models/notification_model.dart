import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  reelView,
  system,
}

NotificationType notificationTypeFromString(String type) {
  return NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
    orElse: () => NotificationType.system, // fallback
  );
}

String notificationTypeToString(NotificationType type) {
  return type.toString().split('.').last;
}

class NotificationModel {
  final String notificationID;
  final String notificationDescription;
  final String userID;
  final String? reelID;
  final NotificationType notificationType;
  final Timestamp timestamp;
  final bool isRead;

  NotificationModel({
    required this.notificationID,
    required this.notificationDescription,
    required this.userID,
    this.reelID,
    required this.notificationType,
    required this.timestamp,
    this.isRead = false
  });

  Map<String, dynamic> toMap() {
    return {
      'notificationID': notificationID,
      'notificationDescription': notificationDescription,
      'userID': userID,
      'reelID': reelID,
      'notificationType': notificationTypeToString(notificationType),
      'timestamp': timestamp,
      'isRead' : isRead
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationID: map['notificationID'] ?? '',
      notificationDescription: map['notificationDescription'] ?? '',
      userID: map['userID'] ?? '',
      reelID: map['reelID'],
      notificationType: notificationTypeFromString(map['notificationType'] ?? 'system'),
      timestamp: map['timestamp'] ?? Timestamp.now(),
      isRead: map['isRead'] ?? false
    );
  }
}