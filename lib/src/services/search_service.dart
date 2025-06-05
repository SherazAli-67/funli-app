import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class SearchService {
  static final _reelsColRef = FirebaseFirestore.instance.collection(FirebaseConstants.reelsCollection);
  static Future<List<ReelModel>> getReels(String query) async {
    try {
      final  querySnapshot = await _reelsColRef
          .where('moodTag', isEqualTo: query)
          .get();

      return querySnapshot.docs
          .map((doc) => ReelModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching reels for search results: $e');
      return [];
    }
  }
}