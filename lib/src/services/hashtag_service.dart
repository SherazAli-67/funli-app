import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/follow_model.dart';
import 'package:funli_app/src/models/hashtag_model.dart';
import 'package:funli_app/src/models/mood_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class HashtagService {
  static final CollectionReference _userColRef =  FirebaseFirestore.instance.collection(FirebaseConstants.userCollection);
  static final CollectionReference _hashtagCollectionsRef =  FirebaseFirestore.instance.collection(FirebaseConstants.hashtagsCollections);
  static Stream<bool> getIsFollowing({required String hashtag}){
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    final userFollowingHashtagRef = _userColRef
        .doc(currentUID)
        .collection(FirebaseConstants.followingHashtagCollections)
        .doc(hashtag);
    return userFollowingHashtagRef.snapshots().map((snapshot)=> snapshot.exists);
  }


  static Future<bool> oddToFollow({required String hashtag, bool isUnfollowRequest = false})async{
    bool result = false;
    String currentUID = FirebaseAuth.instance.currentUser!.uid;

    final userFollowingHashtagRef = _userColRef
        .doc(currentUID)
        .collection(FirebaseConstants.followingHashtagCollections)
        .doc(hashtag);

    final hashtagFollowersColRef = _hashtagCollectionsRef
        .doc(hashtag)
        .collection(FirebaseConstants.followersCollection)
        .doc(currentUID);

    try{
      if(isUnfollowRequest){
        await userFollowingHashtagRef.delete();
        await hashtagFollowersColRef.delete();
      }else{
        DateTime now = DateTime.now();
        FollowModel follow = FollowModel(userID: currentUID, dateTime: now);

        await userFollowingHashtagRef.set({'tag' : hashtag, 'dateTime' : now.toIso8601String()});
        await hashtagFollowersColRef.set(follow.toMap());
      }
    }catch(e){
      debugPrint("Error while addToFollowRequest: ${e.toString()}");
    }


    return result;
  }

  static Future<List<HashtagModel>> getTrendingHashtags({int limit = 4}) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirebaseConstants.hashtagsCollections)
        .orderBy('reelsCount', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc)=>  HashtagModel.fromMap(doc.data())).toList();
  }

  static Future<List<MoodModel>> getTrendingMoods({int limit = 4}) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirebaseConstants.moodsCollection)
        .orderBy('reelsCount', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc)=>  MoodModel.fromMap(doc.data())).toList();
  }
}