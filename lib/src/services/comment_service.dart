import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/comment_model.dart';
import '../res/firebase_constants.dart';

class CommentService {
  static final _reelsColRef = FirebaseFirestore.instance.collection(FirebaseConstants.reelsCollection);

  static Future<void> addCommentToReel({required String reelID, required String commentText})async{
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    DateTime now = DateTime.now();
    String commentID = now.microsecondsSinceEpoch.toString();

    AddCommentModel comment = AddCommentModel(
        commentID: commentID,
        commentBy: currentUID,
        dateTime: DateTime.now(),
        comment: commentText);
    await _reelsColRef
        .doc(reelID)
        .collection(FirebaseConstants.commentsCollection)
        .doc(commentID).set(comment.toMap());

  }

  static Future<void> addReplyToComment({required String reelID, required String commentID, required String replyText})async{

    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    DateTime now = DateTime.now();
    String replyID = now.microsecondsSinceEpoch.toString();

    AddCommentModel reply = AddCommentModel(
        commentID: replyID,
        commentBy: currentUID,
        dateTime: DateTime.now(),
        comment: replyText);
    await _reelsColRef
        .doc(reelID)
        .collection(FirebaseConstants.commentsCollection)
        .doc(commentID).collection(FirebaseConstants.repliesCollection).doc(replyID).set(reply.toMap());

  }

  static Stream<int> getCommentsReplyCount({required String reelID, required String commentID})  {
   return _reelsColRef.doc(reelID)
        .collection(FirebaseConstants.commentsCollection)
        .doc(commentID)
        .collection(FirebaseConstants.repliesCollection).snapshots().map((snapshot)=> snapshot.size);

  }

  static Future<List<AddCommentModel>> getCommentsReply({required String reelID, required String commentID}) async{
    QuerySnapshot querySnapshot = await _reelsColRef.doc(reelID)
        .collection(FirebaseConstants.commentsCollection)
        .doc(commentID)
        .collection(FirebaseConstants.repliesCollection).get();

    return querySnapshot.docs.map((doc)=> AddCommentModel.fromMap(doc.data() as Map<String,dynamic>)).toList();
  }

  static Future<void> markCommentAsPinned({required String reelID, required AddCommentModel comment})async {
    await _reelsColRef.doc(reelID)
        .collection(FirebaseConstants.commentsCollection)
        .doc(comment.commentID).update({
      'isPinned' : !comment.isPinned
    });

  }
}