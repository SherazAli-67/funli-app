import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/reel_model.dart';
import '../res/firebase_constants.dart';

class MoodReelsProvider extends ChangeNotifier {
  List<ReelModel> reels = [];
  DocumentSnapshot? _lastDoc;
  bool isLoading = false;
  bool hasMore = true;
  final int limit = 5;

  Future<void> fetchInitialReels({required String mood}) async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirebaseConstants.moodsCollection)
        .doc(mood)
        .collection(FirebaseConstants.reelsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    _lastDoc = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
    final reelIDs = querySnapshot.docs.map((doc) => doc.id).toList();

    reels = await _getReelsFromIDs(reelIDs);
    hasMore = reelIDs.length == limit;

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreReels({required String mood}) async {
    if (isLoading || !hasMore || _lastDoc == null) return;

    isLoading = true;
    notifyListeners();

    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirebaseConstants.moodsCollection)
        .doc(mood)
        .collection(FirebaseConstants.reelsCollection)
        .orderBy('timestamp', descending: true)
        .startAfterDocument(_lastDoc!)
        .limit(limit)
        .get();

    final reelIDs = querySnapshot.docs.map((doc) => doc.id).toList();
    _lastDoc = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : _lastDoc;
    final newReels = await _getReelsFromIDs(reelIDs);

    reels.addAll(newReels);
    hasMore = reelIDs.length == limit;

    isLoading = false;
    notifyListeners();
  }

  Future<List<ReelModel>> _getReelsFromIDs(List<String> ids) async {
    List<ReelModel> result = [];

    for (final id in ids) {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseConstants.reelsCollection)
          .doc(id)
          .get();

      if (doc.exists) {
        result.add(ReelModel.fromMap(doc.data() as Map<String, dynamic>));
      }
    }

    return result;
  }
}