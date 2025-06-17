import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/reel_model.dart';
import '../res/firebase_constants.dart';

class FeelsSearchProvider extends ChangeNotifier {
  final List<ReelModel> _reels = [];
  DocumentSnapshot? lastDoc;
  bool _hasMore = true;
  bool _isLoading = false;

  String? _query;

  List<ReelModel> get reels => _reels;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Future<void> fetchReelsByQuery({required String query}) async {

    _query = query;
    _reels.clear();
    lastDoc = null;
    _hasMore = true;
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    debugPrint("Fetching reels by query");
    final userQuerySnap = await FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .where('userName', isGreaterThanOrEqualTo: query)
        .where('userName', isLessThan: '${query}z')
        .get();

    final userIDs = userQuerySnap.docs.map((doc) => doc.id).toList();

    Query<Map<String, dynamic>> queryRef = FirebaseFirestore.instance
        .collection(FirebaseConstants.reelsCollection);

// Search by caption
//     if (query.isNotEmpty) {
//       queryRef = queryRef
//           .where('caption', isGreaterThanOrEqualTo: query)
//           .where('caption', isLessThan: '${query}z');
//     }

// Additionally filter by matching userIDs (if any found)
    if (userIDs.isNotEmpty) {
      queryRef = queryRef.where('userID', whereIn: userIDs.take(5).toList()); // Firestore limit
    }

// Fetch
    final snapshot = await queryRef.get();
    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
      _reels.addAll(snapshot.docs.map((e) => ReelModel.fromMap(e.data())));
    }

    debugPrint("Queried reels received: ${_reels.length}");
    if (snapshot.docs.length < 10) {
      _hasMore = false;
    }

    _isLoading = false;
    notifyListeners();
  }
  Future<void> fetchInitial({String? query}) async {
    _query = query;
    _reels.clear();
    lastDoc = null;
    _hasMore = true;
    await _fetchReels();
  }

  Future<void> fetchMore() async {
    if (!_hasMore || _isLoading) return;
    await _fetchReels();
  }

  Future<void> _fetchReels() async {
    debugPrint("Getting reels for search: $_query");
    _isLoading = true;
    notifyListeners();

    Query queryRef = FirebaseFirestore.instance
        .collection(FirebaseConstants.reelsCollection)
        .orderBy('createdAt', descending: true)
        .limit(10);

    /*if (_query != null && _query!.isNotEmpty) {
      queryRef =
          queryRef..where('userName', isGreaterThanOrEqualTo: _query)
              .where('userName', isLessThan: '${_query}z');
    }*/

    if (lastDoc != null) {
      queryRef = queryRef.startAfterDocument(lastDoc!);
    }

    final snapshot = await queryRef.get();
    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
      _reels.addAll(snapshot.docs.map((e) => ReelModel.fromMap(e.data() as Map<String, dynamic>)));
    }

    debugPrint("Reels received: ${_reels.length}");
    if (snapshot.docs.length < 10) {
      _hasMore = false;
    }

    _isLoading = false;
    notifyListeners();
  }
}