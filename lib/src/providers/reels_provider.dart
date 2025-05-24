// providers/reel_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/services/reels_service.dart';
import '../models/reel_model.dart';

class ReelProvider with ChangeNotifier {
  final ReelsService _service = ReelsService();

  String?_currentUserID;
  String? _selectedMood;
  final int _limit = 10;
  final List<ReelModel> _reels = [];
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get currentUserID => _currentUserID ?? FirebaseAuth.instance.currentUser!.uid;
  String get selectedMood => _selectedMood ?? 'Happy';

  List<ReelModel> get reels => _reels;


  Future<void> fetchReels() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    final newReels = await _service.fetchReels(
      userId: currentUserID,
      selectedMood: selectedMood,
      lastDoc: _lastDoc,
      limit: _limit,
      onLastDoc: (doc) => _lastDoc = doc,
      onHasMore: (has) => _hasMore = has,
    );

    _reels.addAll(newReels);

    _isLoading = false;
    notifyListeners();
  }
}