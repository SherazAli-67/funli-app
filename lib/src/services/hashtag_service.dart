import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/follow_model.dart';
import 'package:funli_app/src/models/hashtag_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class HashtagService {
  static final CollectionReference _hashtagCollectionsRef =  FirebaseFirestore.instance.collection(FirebaseConstants.hashtagsCollections);
  static Stream<bool> getIsFollowing({required String hashtag}){
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    return _hashtagCollectionsRef.doc(hashtag).collection(
        FirebaseConstants.followersCollection).doc(currentUID).snapshots().map((
        snapshot) => snapshot.exists);
  }


  static Future<bool> oddToFollow({required String hashtag, bool isUnfollowRequest = false})async{
    bool result = false;
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    try{
      if(isUnfollowRequest){
        await _hashtagCollectionsRef.doc(hashtag).collection(FirebaseConstants.followersCollection).doc(currentUID).delete();
      }else{
        FollowModel follow = FollowModel(userID: currentUID, dateTime: DateTime.now());
        await _hashtagCollectionsRef.doc(hashtag).collection(FirebaseConstants.followersCollection).doc(currentUID).set(follow.toMap());
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

}