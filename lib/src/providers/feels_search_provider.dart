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

    debugPrint("Fetching reels by query: $query");
    
    try {
      // Search for users with case-insensitive approach
      String lowerQuery = query.toLowerCase();
      String upperQuery = query.toUpperCase();
      
      // First, get users that match the query (case-insensitive)
      final userQuerySnap = await FirebaseFirestore.instance
          .collection(FirebaseConstants.userCollection)
          .get();
      
      // Filter users client-side for better case-insensitive matching
      final matchingUsers = userQuerySnap.docs.where((doc) {
        final userData = doc.data() as Map<String, dynamic>;
        final userName = userData['userName']?.toString().toLowerCase() ?? '';
        return userName.contains(lowerQuery);
      }).toList();

      final userIDs = matchingUsers.map((doc) => doc.id).toList();

      if (userIDs.isEmpty) {
        debugPrint("No matching users found for query: $query");
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Search reels by matching userIDs
      Query<Map<String, dynamic>> queryRef = FirebaseFirestore.instance
          .collection(FirebaseConstants.reelsCollection)
          .orderBy('createdAt', descending: true);

      // Split userIDs into chunks of 10 (Firestore whereIn limit)
      List<List<String>> userIDChunks = [];
      for (int i = 0; i < userIDs.length; i += 10) {
        userIDChunks.add(userIDs.skip(i).take(10).toList());
      }

      List<ReelModel> allReels = [];
      
      // Fetch reels for each chunk of userIDs
      for (List<String> chunk in userIDChunks) {
        final snapshot = await queryRef
            .where('userID', whereIn: chunk)
            .limit(20)
            .get();
            
        if (snapshot.docs.isNotEmpty) {
          allReels.addAll(snapshot.docs.map((e) => ReelModel.fromMap(e.data())));
        }
      }

      // Sort by creation date and take first 20
      allReels.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      _reels.addAll(allReels.take(20));

      if (allReels.isNotEmpty) {
        lastDoc = null; // Reset for this search approach
      }

      debugPrint("Queried reels received: ${_reels.length}");
      if (_reels.length < 10) {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint("Error in fetchReelsByQuery: $e");
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
