import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/models/user_model.dart';
import '../res/firebase_constants.dart';

class UsersSearchProvider extends ChangeNotifier {
  List<UserModel> _users = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoading = false;

  String? _query;

  List<UserModel> get users => _users;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Future<void> fetchInitial({String? query}) async {
    _query = query;
    _users.clear();
    _lastDoc = null;
    _hasMore = true;
    await _fetchUsers();
  }

  Future<void> fetchMore() async {
    if (!_hasMore || _isLoading) return;
    await _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    debugPrint("Getting users for query: $_query");
    _isLoading = true;
    notifyListeners();

    try {
      if (_query != null && _query!.isNotEmpty) {
        // For search queries, use case-insensitive client-side filtering
        String lowerQuery = _query!.toLowerCase();
        
        // Get all users first (or a reasonable batch)
        Query queryRef = FirebaseFirestore.instance
            .collection(FirebaseConstants.userCollection)
            .limit(50); // Get more to filter client-side
            
        if (_lastDoc != null) {
          queryRef = queryRef.startAfterDocument(_lastDoc!);
        }

        final snapshot = await queryRef.get();
        
        // Filter client-side for case-insensitive matching
        final filteredUsers = snapshot.docs.where((doc) {
          final userData = doc.data() as Map<String, dynamic>;
          final userName = userData['userName']?.toString().toLowerCase() ?? '';
          return userName.contains(lowerQuery);
        }).take(10).toList(); // Take only 10 matching results

        if (filteredUsers.isNotEmpty) {
          _lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
          _users.addAll(filteredUsers.map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>)));
        }

        if (filteredUsers.length < 10) {
          _hasMore = false;
        }
      } else {
        // For empty query, get all users normally
        Query queryRef = FirebaseFirestore.instance
            .collection(FirebaseConstants.userCollection)
            .limit(10);

        if (_lastDoc != null) {
          queryRef = queryRef.startAfterDocument(_lastDoc!);
        }

        final snapshot = await queryRef.get();
        if (snapshot.docs.isNotEmpty) {
          _lastDoc = snapshot.docs.last;
          _users.addAll(snapshot.docs.map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>)));
        }

        if (snapshot.docs.length < 10) {
          _hasMore = false;
        }
      }
    } catch (e) {
      debugPrint("Error in _fetchUsers: $e");
    }

    debugPrint("users received: ${_users.length}");
    _isLoading = false;
    notifyListeners();
  }
}
