class ShareReelModel {
  final String shareID;
  final String reelID;
  final String sharedByUID;
  final DateTime dateTime;

  ShareReelModel({
    required this.reelID,
    required this.sharedByUID,
    required this.dateTime,
    required this.shareID
  });

  Map<String, dynamic> toMap() {
    return {
      'shareID' : shareID,
      'reelID' :  reelID,
      "shareByUID" : sharedByUID,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory ShareReelModel.fromMap(Map<String, dynamic> map) {
    return ShareReelModel(
      shareID: map['shareID'],
      reelID: map['reelID'],
      sharedByUID: map['shareByUID'],
      dateTime: DateTime.tryParse(map['dateTime'])!,
    );
  }
}