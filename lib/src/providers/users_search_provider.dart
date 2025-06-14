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

    debugPrint("Getting users: ");
    _isLoading = true;
    notifyListeners();

    Query queryRef = FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .limit(10);

    if (_query != null && _query!.isNotEmpty) {
      queryRef =
          queryRef.where('userName', isGreaterThanOrEqualTo: _query!).where(
              'userName', isLessThanOrEqualTo: '${_query!}\uf8ff');
    }

    if (_lastDoc != null ) {
      queryRef = queryRef.startAfterDocument(_lastDoc!);
    }

    final snapshot = await queryRef.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      _users.addAll(snapshot.docs.map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>)));
      notifyListeners();
    }

    if (snapshot.docs.length < 10) {
      _hasMore = false;
    }
    debugPrint("users received: ${_users.length}");
    _isLoading = false;
    notifyListeners();
  }
}