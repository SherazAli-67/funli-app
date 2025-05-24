import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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

      Query baseQuery = _firestore.collection('reels');

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
      debugPrint("Reels found: ${snapshot.size}");
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

}