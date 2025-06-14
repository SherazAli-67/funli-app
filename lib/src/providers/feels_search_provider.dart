import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/reel_model.dart';
import '../res/firebase_constants.dart';

class FeelsSearchProvider extends ChangeNotifier {
  List<ReelModel> _reels = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoading = false;

  String? _query;

  List<ReelModel> get reels => _reels;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Future<void> fetchInitial({String? query}) async {
    _query = query;
    _reels.clear();
    _lastDoc = null;
    _hasMore = true;
    await _fetchReels();
  }

  Future<void> fetchMore() async {
    if (!_hasMore || _isLoading) return;
    await _fetchReels();
  }

  Future<void> _fetchReels() async {
    debugPrint("Getting reels for search");
    _isLoading = true;
    notifyListeners();

    Query queryRef = FirebaseFirestore.instance
        .collection(FirebaseConstants.reelsCollection)
        .orderBy('createdAt', descending: true)
        .limit(10);

    if (_query != null && _query!.isNotEmpty) {
      queryRef =
          queryRef.where('caption', isGreaterThanOrEqualTo: _query!).where(
              'caption', isLessThanOrEqualTo: '${_query!}\uf8ff');
    }

    if (_lastDoc != null) {
      queryRef = queryRef.startAfterDocument(_lastDoc!);
    }

    final snapshot = await queryRef.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
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