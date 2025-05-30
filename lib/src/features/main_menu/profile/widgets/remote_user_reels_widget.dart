
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class RemoteUserReelsWidget extends StatefulWidget {
  const RemoteUserReelsWidget({
    super.key,
    required String userID,
    String? userName,
  })  : _userID = userID,
        _userName = userName;

  final String _userID;
  final String? _userName;

  @override
  State<RemoteUserReelsWidget> createState() => _RemoteUserReelsWidgetState();
}

class _RemoteUserReelsWidgetState extends State<RemoteUserReelsWidget> {
  final List<DocumentSnapshot> _reels = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _limit = 4;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _fetchReels(isFirstTime: true);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && !_isLoading && _hasMore) {
      _fetchReels();
    }
  }

  Future<void> _fetchReels({bool isFirstTime = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection(FirebaseConstants.reelsCollection)
        .where("userID", isEqualTo: widget._userID)
        // .orderBy("createdAt", descending: true)
        .limit(_limit);

    if (_lastDocument != null && !isFirstTime) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final querySnapshot = await query.get();
    final docs = querySnapshot.docs;

    if (docs.isNotEmpty) {
      _lastDocument = docs.last;
      _reels.addAll(docs);
    }

    setState(() {
      _isLoading = false;
      if (docs.length < _limit) {
        _hasMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_reels.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reels.isEmpty) {
      return const Center(child: Text("No reels found."));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 9 / 16,
      ),
      itemCount: _reels.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _reels.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final reelData = _reels[index].data() as Map<String, dynamic>;
        final thumbnailUrl = reelData['thumbnailUrl'] ?? AppIcons.icDummyImgUrl;

        return GestureDetector(
          onTap: () {
            // open reel detail page if needed
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(thumbnailUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}