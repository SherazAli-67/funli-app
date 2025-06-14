import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/models/hashtag_model.dart';
import '../res/firebase_constants.dart';

class HashtagSearchProvider extends ChangeNotifier {
  final List<HashtagModel> _hashtags = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoading = false;

  String? _query;

  List<HashtagModel> get tags => _hashtags;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Future<void> fetchInitial({String? query}) async {
    _query = query;
    _hashtags.clear();
    _lastDoc = null;
    _hasMore = true;
    await _fetchTags();
  }

  Future<void> fetchMore() async {
    if (!_hasMore || _isLoading) return;
    await _fetchTags();
  }

  Future<void> _fetchTags() async {
    _isLoading = true;
    notifyListeners();

    Query queryRef = FirebaseFirestore.instance
        .collection(FirebaseConstants.hashtagsCollections)
        .orderBy('reelsCount', descending: true)
        .limit(5);

    if (_query != null && _query!.isNotEmpty) {
      queryRef =
          queryRef.where('tag', isGreaterThanOrEqualTo: _query!).where(
              'tag', isLessThanOrEqualTo: '${_query!}\uf8ff');
    }

    if (_lastDoc != null) {
      queryRef = queryRef.startAfterDocument(_lastDoc!);
    }

    final snapshot = await queryRef.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      _hashtags.addAll(snapshot.docs.map((e) => HashtagModel.fromMap(e.data() as Map<String, dynamic>)));
    }

    if (snapshot.docs.length < 10) {
      _hasMore = false;
    }

    _isLoading = false;
    notifyListeners();
  }
}