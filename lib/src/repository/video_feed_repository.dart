import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

import 'i_video_feed_repository.dart';

class VideoFeedRepository implements IVideoFeedRepository {
  VideoFeedRepository(this._firestore);

  final FirebaseFirestore _firestore;
  DocumentSnapshot? _lastDocument;

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
      // List<String> videos = [
      //   'https://firebasestorage.googleapis.com/v0/b/funli-app.firebasestorage.app/o/reels%2FsTAMOezkAJPaDTzCqD8zhQAScjA3%2F1748713520829223%2Fvideo.mp4?alt=media&token=1e71f097-8560-4035-b8af-b20ec7661bba',
      //   'https://firebasestorage.googleapis.com/v0/b/funli-app.firebasestorage.app/o/reels%2FsTAMOezkAJPaDTzCqD8zhQAScjA3%2F1748713649560489%2Fvideo.mp4?alt=media&token=5f4ade1e-d3fc-4ca6-bd8e-59b2943ea183',
      //   'https://firebasestorage.googleapis.com/v0/b/funli-app.firebasestorage.app/o/reels%2FsTAMOezkAJPaDTzCqD8zhQAScjA3%2F1748713745288959%2Fvideo.mp4?alt=media&token=5de41384-8c43-4c9c-a3c1-726ba02287e4',
      //   'https://firebasestorage.googleapis.com/v0/b/funli-app.firebasestorage.app/o/reels%2F6KxwzfSlnvPnuCzlMUAP0lVVhHs1%2F1749814334619926%2Fvideo.mp4?alt=media&token=f06c234f-02d9-4d79-bdc3-79ed2854e9ff',
      //   'https://firebasestorage.googleapis.com/v0/b/funli-app.firebasestorage.app/o/reels%2F6KxwzfSlnvPnuCzlMUAP0lVVhHs1%2F1749814507937285%2Fvideo.mp4?alt=media&token=8b9dd46d-a4b4-414b-b388-9da308ae6fbd',
      //   'https://firebasestorage.googleapis.com/v0/b/funli-app.firebasestorage.app/o/reels%2FFML1JYdoiUYjG0EwZ7RYNMQqmU73%2F1749814721486883%2Fvideo.mp4?alt=media&token=c82076bf-75f6-42ac-9fdb-2b55e49df6d8',
      //   'https://firebasestorage.googleapis.com/v0/b/funli-app.firebasestorage.app/o/reels%2F6KxwzfSlnvPnuCzlMUAP0lVVhHs1%2F1749814978384072%2Fvideo.mp4?alt=media&token=14054ce0-1877-4a35-94d8-c8faa995cc49',
      //   'https://firebasestorage.googleapis.com/v0/b/funli-app.firebasestorage.app/o/reels%2FLn0Ls1d2buVqTs7c4wgkkTUVSk63%2F1749825881929476%2Fvideo.mp4?alt=media&token=b968c1ff-13f6-48c2-9290-0ce2cad636d2',
      //   'https://firebasestorage.googleapis.com/v0/b/funli-app.firebasestorage.app/o/reels%2FsTAMOezkAJPaDTzCqD8zhQAScjA3%2F1749899925326936%2Fvideo.mp4?alt=media&token=cc1799d7-4d89-4c68-bbaf-604bfc303c4c',
      //   'https://firebasestorage.googleapis.com/v0/b/funli-app.firebasestorage.app/o/reels%2FsTAMOezkAJPaDTzCqD8zhQAScjA3%2F1749909828584371%2Fvideo.mp4?alt=media&token=cfd49077-da09-429f-9f28-851f83532d57'
      //
      // ];
      // return List.generate(10, (index){
      //   return VideoItem(id: index.toString(),
      //       username: "Index: ${index+1}",
      //       description: "description",
      //       videoUrl: videos[index],
      //       profileImageUrl: "profileImageUrl",
      //       likeCount: 32986,
      //       commentCount: 10,
      //       shareCount: 5,
      //       isBookmarked: false,
      //       isLiked: index %2 == 0,
      //       timestamp: DateTime.now());
      // });

      Query query = _firestore
          .collection(FirebaseConstants.reelsCollection)
          .orderBy('createdAt', descending: true)
          // .orderBy(FieldPath.documentId, descending: false)
          .limit(2);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      final snapshot = await query.get();

      debugPrint("Reels received: ${snapshot.docs.length}");
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
