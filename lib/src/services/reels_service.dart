import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/comment_model.dart';
import 'package:funli_app/src/models/like_model.dart';
import 'package:funli_app/src/providers/reels_provider.dart';
import 'package:funli_app/src/res/firebase_constants.dart';
import 'package:provider/provider.dart';

import '../models/reel_model.dart';

class ReelsService {
  static final _reelsColRef = FirebaseFirestore.instance
      .collection(FirebaseConstants.reelsCollection);

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
      Query baseQuery = _reelsColRef.orderBy('createdAt', descending: true);

      final snapshot = await baseQuery.get();
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
    final likeDocRef = _reelsColRef
        .doc(reelID)
        .collection(FirebaseConstants.likesCollection);

    return likeDocRef.snapshots().map((snapshot)=> snapshot.docs.map((doc)=> doc.id).toList());
  }

  static Future<int> getReelLikesCount({required String reelID}) async{

    final countQuery = await _reelsColRef
        .doc(reelID)
        .collection(FirebaseConstants.likesCollection).count().get();

    final totalCount = countQuery.count ?? 0;
    return totalCount;

    // return likeDocRef.snapshots().map((snapshot)=> snapshot.docs.map((doc)=> doc.id).toList());
  }

  static Stream<List<String>> getCommentLikes({required String reelID, required String commentID}) {
    final likeDocRef = _reelsColRef
        .doc(reelID)
        .collection(FirebaseConstants.commentsCollection).doc(commentID).collection(
        FirebaseConstants.likesCollection);

    return likeDocRef.snapshots().map((snapshot)=> snapshot.docs.map((doc)=> doc.id).toList());
  }

  static Stream<int> getReelCommentCount({required String reelID}) {
    return  _reelsColRef
        .doc(reelID)
        .collection(FirebaseConstants.commentsCollection)
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
          .collection(FirebaseConstants.userCollection)
          .doc(currentUID)
          .collection(FirebaseConstants.likesCollection)
          .doc(reelID);

      final postLikeRef = _reelsColRef
          .doc(reelID)
          .collection(FirebaseConstants.likesCollection)
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


  static Future<bool> addLikeToComment({required String reelID, required String commentID, required bool isRemove})async{
    bool isLiked = false;

    try {
      String currentUID = FirebaseAuth.instance.currentUser!.uid;

      final commentLikeRef = _reelsColRef
          .doc(reelID)
          .collection(FirebaseConstants.commentsCollection).doc(commentID).collection(
          FirebaseConstants.likesCollection).doc(currentUID);
      if (isRemove) {
        //removing like from likes collection
        await commentLikeRef.delete();
        isLiked = true;
      } else {
        DateTime dateTime = DateTime.now();
        LikeModel like = LikeModel(likedBy: currentUID, dateTime: dateTime);
        await commentLikeRef.set(like.toMap());
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
    await _reelsColRef
        .doc(reelID)
        .collection(FirebaseConstants.commentsCollection)
        .doc(commentID).set(comment.toMap());

  }

  static Stream<List<AddCommentModel>> getReelsComment({required String reelID}) {
    return _reelsColRef
        .doc(reelID)
        .collection(FirebaseConstants.commentsCollection).snapshots().map((
        snapshot) =>
        snapshot.docs.map((doc) => AddCommentModel.fromMap(doc.data()))
            .toList());
  }

  static Future<List<ReelModel>> getUserReels({required int limit}) async{
   QuerySnapshot querySnapshot =  await _reelsColRef.limit(limit).get();
  return querySnapshot.docs.map((doc)=> ReelModel.fromMap(doc.data() as Map<String,dynamic>)).toList();
  }

  static Future<int> getHashtagReelsCount({required String hashtag}) async{
    final countQuery = await FirebaseFirestore.instance
        .collection(FirebaseConstants.hashtagsCollections).doc(hashtag)
        .collection(FirebaseConstants.reelsCollection).count()
        .get();

    final totalCount = countQuery.count ?? 0;
    return totalCount;
  }

  static Future<void> addViewToReel({required BuildContext context,  required String reelID}) async{
    final provider = Provider.of<ReelProvider>(context, listen: false);
    provider.addReelToView(reelID);

    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('reels')
        .doc(reelID)
        .collection('views')
        .doc(currentUID);

    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      debugPrint("Adding view to $reelID");
      await docRef.set(
          {
            'userID' : currentUID,
            'viewedAt': FieldValue.serverTimestamp(),
          }
      );
    }else{
      debugPrint("Already viewed $reelID");
    }
  }
}