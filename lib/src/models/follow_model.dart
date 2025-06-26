class FollowModel {
  final String userID;
  final DateTime dateTime;
  final bool isApproved;

  FollowModel({
    required this.userID,
    required this.dateTime,
    this.isApproved = false
  });

  Map<String, dynamic> toMap() {
    return {
      "userID" : userID,
      'dateTime': dateTime.toIso8601String(),
      'isApproved': isApproved
    };
  }

  factory FollowModel.fromMap(Map<String, dynamic> map) {
    return FollowModel(
      userID: map['userID'],
      dateTime: DateTime.tryParse(map['dateTime'])!,
      isApproved: map['isApproved'] ?? false
    );
  }
}