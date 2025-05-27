class AddCommentModel {
  final String commentID;
  final String commentBy;
  final DateTime dateTime;
  final String comment;

  AddCommentModel({
    required this.commentID,
    required this.commentBy,
    required this.dateTime,
    required this.comment
  });

  Map<String, dynamic> toMap() {
    return {
      'commentID' :  commentID,
      "commentBy" : commentBy,
      'dateTime': dateTime.toIso8601String(),
      'comment' :  comment
    };
  }

  factory AddCommentModel.fromMap(Map<String, dynamic> map) {
    return AddCommentModel(
      commentID: map['commentID'],
      commentBy: map['commentBy'],
      dateTime: DateTime.tryParse(map['dateTime'])!,
      comment: map['comment']
    );
  }
}