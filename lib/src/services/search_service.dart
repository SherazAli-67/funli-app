import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/hashtag_model.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class SearchService {
  static final _reelsColRef = FirebaseFirestore.instance.collection(FirebaseConstants.reelsCollection);
  static final _hashtagColRef = FirebaseFirestore.instance.collection(FirebaseConstants.hashtagsCollections);

  static final _usersColRef = FirebaseFirestore.instance.collection(FirebaseConstants.userCollection);

  static Stream<List<ReelModel>> getReelsStream(String query)  {
    return _reelsColRef.where('userName', isGreaterThanOrEqualTo: query)
        .where('userName', isLessThan: '${query}z').snapshots().map((
        snapshot) =>
        snapshot.docs.map((doc) => ReelModel.fromMap(doc.data())).toList());
  }

  static Stream<List<HashtagModel>> getTags(String query)  {
    return _hashtagColRef.where('tag', isGreaterThanOrEqualTo: query)
        .where('tag', isLessThan: '${query}z').snapshots().map((
        snapshot) =>
        snapshot.docs.map((doc) => HashtagModel.fromMap(doc.data())).toList());
  }

  static Future<List<ReelModel>> getReels(String query) async {
    if (query.trim().isEmpty) {
      return []; // return empty if query is empty
    }
    try {

      final  querySnapshot = await _reelsColRef
          .where('moodTag', isGreaterThanOrEqualTo: query)
          .where('moodTag', isLessThan: '${query}z')
          .get();

      return querySnapshot.docs
          .map((doc) => ReelModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching reels for search results: $e');
      return [];
    }
  }

  static Future<List<UserModel>> getUsers(String query) async {
    if (query.trim().isEmpty) {
      return []; // return empty if query is empty
    }
    try {
      final querySnapshot = await _usersColRef
        .where('userName', isGreaterThanOrEqualTo: query)
        .where('userName', isLessThan: '${query}z')
          .get();

      debugPrint("User found for query: $query are ${querySnapshot.size}");
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

    } catch (e) {
      debugPrint('❌ Error fetching reels for search results: $e');
      return [];
    }
  }
}