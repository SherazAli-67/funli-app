class LikeModel {
  final String likedBy;
  final DateTime dateTime;


  LikeModel({
    required this.likedBy,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      "likedBy" : likedBy,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory LikeModel.fromMap(Map<String, dynamic> map) {
    return LikeModel(
      likedBy: map['userID'],
      dateTime: DateTime.tryParse(map['dateTime'])!,
    );
  }
}