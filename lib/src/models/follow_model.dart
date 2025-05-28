class FollowModel {
  final String userID;
  final DateTime dateTime;


  FollowModel({
    required this.userID,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      "userID" : userID,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory FollowModel.fromMap(Map<String, dynamic> map) {
    return FollowModel(
      userID: map['userID'],
      dateTime: DateTime.tryParse(map['dateTime'])!,
    );
  }
}