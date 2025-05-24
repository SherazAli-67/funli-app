import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReelFeedWidget extends StatefulWidget {
  final String currentUserId;
  final String selectedMood;

  const ReelFeedWidget({
    required this.currentUserId,
    required this.selectedMood,
    super.key,
  });

  @override
  State<ReelFeedWidget> createState() => _ReelFeedWidgetState();
}

class _ReelFeedWidgetState extends State<ReelFeedWidget> {
  List<DocumentSnapshot> _reels = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchReels();
  }

  Future<void> _fetchReels() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();

      final List<String> followings =
      List<String>.from(userDoc.data()?['followings'] ?? []);

      Query baseQuery = FirebaseFirestore.instance.collection('reels');

      if (followings.isEmpty) {
        // New user: trending + mood
        baseQuery = baseQuery
            .where('mood', isEqualTo: widget.selectedMood)
            .orderBy('likes', descending: true)
            .orderBy('createdAt', descending: true);
      } else {
        // Low/active user: fetch from followings
        baseQuery = baseQuery
            .where('creatorId', whereIn: followings.take(10).toList())
            .orderBy('createdAt', descending: true);
      }

      if (_lastDoc != null) {
        baseQuery = baseQuery.startAfterDocument(_lastDoc!);
      }

      final QuerySnapshot snapshot = await baseQuery.limit(_limit).get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _lastDoc = snapshot.docs.last;
          _reels.addAll(snapshot.docs);
          _hasMore = snapshot.docs.length == _limit;
        });
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('Error fetching reels: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 300 &&
            !_isLoading && _hasMore) {
          _fetchReels();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _reels.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _reels.length) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ));
          }

          final reel = _reels[index].data() as Map<String, dynamic>;
          return ListTile(
            title: Text("Mood: ${reel['mood']}"),
            subtitle: Text("Likes: ${reel['likes']}"),
            trailing: Text(
              DateTime.fromMillisecondsSinceEpoch(
                  (reel['createdAt'] as Timestamp).millisecondsSinceEpoch)
                  .toString(),
            ),
          );
        },
      ),
    );
  }
}