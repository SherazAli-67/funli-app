class AddCommentModel {
  final String commentID;
  final String commentBy;
  final DateTime dateTime;
  final String comment;
  final bool isPinned;

  AddCommentModel({
    required this.commentID,
    required this.commentBy,
    required this.dateTime,
    required this.comment,
    this.isPinned = false
  });

  Map<String, dynamic> toMap() {
    return {
      'commentID' :  commentID,
      "commentBy" : commentBy,
      'dateTime': dateTime.toIso8601String(),
      'comment' :  comment,
      'isPinned' : isPinned
    };
  }

  factory AddCommentModel.fromMap(Map<String, dynamic> map) {
    return AddCommentModel(
      commentID: map['commentID'],
      commentBy: map['commentBy'],
      dateTime: DateTime.tryParse(map['dateTime'])!,
      comment: map['comment'],
      isPinned: map['isPinned'] ?? false
    );
  }
}