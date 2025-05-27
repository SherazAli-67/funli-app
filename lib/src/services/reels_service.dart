import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/comment_model.dart';
import 'package:funli_app/src/models/like_model.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

import '../models/reel_model.dart';

class ReelsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ReelModel>> fetchReels({
    required String userId,
    required String selectedMood,
    required DocumentSnapshot? lastDoc,
    required int limit,
    required void Function(DocumentSnapshot?) onLastDoc,
    required void Function(bool) onHasMore,
  }) async {
    List<ReelModel> fetchedReels = [];

    try {
      // Get followings from subcollection
     /* final followingSnap = await _firestore
          .collection(userCollection)
          .doc(userId)
          .collection('following')
          .limit(10)
          .get();

      final followings = followingSnap.docs
          .map((doc) => doc['userID'] as String)
          .toList();*/

      Query baseQuery = _firestore.collection(AppConstants.reelsCollection);

     /* if (followings.isEmpty) {
        baseQuery = baseQuery
            .where('moodTag', isEqualTo: selectedMood)
            .orderBy('likes', descending: true)
            .orderBy('createdAt', descending: true);
      } else {
        baseQuery = baseQuery
            .where('creatorId', whereIn: followings)
            .orderBy('createdAt', descending: true);
      }

      if (lastDoc != null) {
        baseQuery = baseQuery.startAfterDocument(lastDoc);
      }*/

      final snapshot = await baseQuery.limit(limit).get();
      if (snapshot.docs.isNotEmpty) {
        onLastDoc(snapshot.docs.last);
        onHasMore(snapshot.docs.length == limit);
        fetchedReels = snapshot.docs
            .map((doc) => ReelModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      } else {
        onHasMore(false);
      }
    } catch (e) {
      debugPrint('Service error: $e');
    }

    return fetchedReels;
  }

  static Stream<List<String>> getReelLikes({required String reelID}) {

    final likeDocRef = FirebaseFirestore.instance
        .collection(AppConstants.reelsCollection)
        .doc(reelID)
        .collection(AppConstants.likesCollection);

    return likeDocRef.snapshots().map((snapshot)=> snapshot.docs.map((doc)=> doc.id).toList());
  }

  static Stream<int> getReelCommentCount({required String reelID}) {
    return  FirebaseFirestore.instance
        .collection(AppConstants.reelsCollection)
        .doc(reelID)
        .collection(AppConstants.commentsCollection)
        .snapshots()
        .map((snapshot) =>
    snapshot.docs.length);
  }

  static Future<bool> addLikeToReel({required String reelID, required bool isRemove})async{
    bool isLiked = false;

    try {
      String currentUID = FirebaseAuth.instance.currentUser!.uid;

      final firebaseFirestore = FirebaseFirestore.instance;

      final userLikeRef = firebaseFirestore
          .collection(userCollection)
          .doc(currentUID)
          .collection(AppConstants.likesCollection)
          .doc(reelID);

      final postLikeRef = firebaseFirestore
          .collection(AppConstants.reelsCollection)
          .doc(reelID)
          .collection(AppConstants.likesCollection)
          .doc(currentUID);
      if (isRemove) {
        // removing liked post from users collection
        await userLikeRef.delete();
        //removing like from likes collection
        await postLikeRef.delete();
        isLiked = true;
      } else {
        String userID = FirebaseAuth.instance.currentUser!.uid;
        DateTime dateTime = DateTime.now();

        //adding reel to user like collections
        await userLikeRef.set({
          'reel' : reelID,
          'dateTime': dateTime
        });



        LikeModel like = LikeModel(likedBy: userID, dateTime: dateTime);
        await postLikeRef.set(like.toMap());
        isLiked = true;
      }
    } catch (e) {
      debugPrint("Exception while adding author to Favorites: ${e.toString()}");
    }


    return isLiked;
  }

  static Future<void> addCommentToReel({required String reelID, required String commentText})async{

    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    DateTime now = DateTime.now();
    String commentID = now.microsecondsSinceEpoch.toString();

    AddCommentModel comment = AddCommentModel(
        commentID: commentID,
        commentBy: currentUID,
        dateTime: DateTime.now(),
        comment: commentText);
    await FirebaseFirestore.instance
        .collection(AppConstants.reelsCollection)
        .doc(reelID)
        .collection(AppConstants.commentsCollection)
        .doc(commentID).set(comment.toMap());

  }

  static Stream<List<AddCommentModel>> getReelsComment({required String reelID}) {
    return FirebaseFirestore.instance
        .collection(AppConstants.reelsCollection)
        .doc(reelID)
        .collection(AppConstants.commentsCollection).snapshots().map((snapshot)=> snapshot.docs.map((doc)=> AddCommentModel.fromMap(doc.data())).toList());
  }
}