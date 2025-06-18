import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';
import 'package:funli_app/src/res/local_storage_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i_video_feed_repository.dart';

class VideoFeedRepository implements IVideoFeedRepository {
  VideoFeedRepository(this._firestore);

  final FirebaseFirestore _firestore;
  DocumentSnapshot? _lastDocument;

  final _reelsColRef = FirebaseFirestore.instance.collection(FirebaseConstants.reelsCollection);
  @override
  Future<List<ReelModel>> fetchVideos() async {
    try {
      // Reset pagination state for a fresh fetch
      _lastDocument = null;
      return await _fetchVideosHelper();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch videos from Firestore: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching videos: $e');
    }
  }

  @override
  Future<List<ReelModel>> fetchMoreVideos() async {
    if (_lastDocument == null) {
      return [];
    }

    try {
      return await _fetchVideosHelper(startAfterDocument: _lastDocument);
    } on FirebaseException catch (e) {
      throw Exception(
        'Failed to fetch more videos from Firestore: ${e.message}',
      );
    } catch (e) {
      throw Exception('Unexpected error while fetching more videos: $e');
    }
  }

  Future<List<ReelModel>> _fetchVideosHelper({
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String mood = sharedPreferences.getString(LocalStorageConstants.currentMoodKey) ?? 'Happy';
      debugPrint("Mood received while fetching reels: ${mood}");
      Query query =
          _reelsColRef.where("moodTag", isEqualTo: mood)
          .orderBy('createdAt', descending: true).limit(2);


      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      final snapshot = await query.get();

      debugPrint("Reels received for mood $mood are ${snapshot.docs.length}");
      if (snapshot.docs.isEmpty) {
        return [];
      }

      _lastDocument = snapshot.docs.last;
      return snapshot.docs.map((doc)=> ReelModel.fromMap(doc.data() as Map<String,dynamic>)).toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error while fetching videos: ${e.message}');
    } catch (e) {
      throw Exception('Error processing video data: $e');
    }
  }
}
