import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';
import 'package:funli_app/src/res/local_storage_constants.dart';
import 'package:funli_app/src/services/reels_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i_video_feed_repository.dart';

class VideoFeedRepository implements IVideoFeedRepository {
  VideoFeedRepository(this._firestore);

  final FirebaseFirestore _firestore;
  DocumentSnapshot? _lastDocument;

  final _reelsColRef = FirebaseFirestore.instance.collection(FirebaseConstants.reelsCollection);
  @override
  Future<List<ReelModel>> fetchVideos({bool isRefresh = false}) async {
    debugPrint("New reels fetching: $isRefresh");
    try {
      // Reset pagination state for a fresh fetch
      _lastDocument = null;
      List<ReelModel> cachedReels = [];
      // Get current mood
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String mood = sharedPreferences.getString(LocalStorageConstants.currentMoodKey) ?? 'Happy';

      // debugPrint("Coming from refresh: $isRefresh");
      if(!isRefresh){
        // First try to load from cache
       cachedReels = await ReelsCacheService.getCachedReels(mood);

        // Check if we need to refresh from network
        final shouldRefresh = await ReelsCacheService.shouldRefreshFromNetwork();

        if (cachedReels.isNotEmpty && !shouldRefresh) {
          debugPrint("Loading ${cachedReels.length} reels from cache for mood: $mood");
          return cachedReels;
        }
      }

      
      // If cache is empty or needs refresh, fetch from network
      final networkReels = await _fetchVideosHelper();
      debugPrint("Network reels received: ${networkReels.length}");
      // Cache the fetched reels
      if (networkReels.isNotEmpty) {
        await ReelsCacheService.cacheReels(networkReels, mood);
      }
      
      // If network fetch failed but we have cached data, return that
      if (networkReels.isEmpty && cachedReels.isNotEmpty) {
        return cachedReels;
      }
      
      return networkReels;
    } on FirebaseException catch (e) {
      // Try to return cached data on network error
      final sharedPreferences = await SharedPreferences.getInstance();
      final mood = sharedPreferences.getString(LocalStorageConstants.currentMoodKey) ?? 'Happy';
      final cachedReels = await ReelsCacheService.getCachedReels(mood);
      
      if (cachedReels.isNotEmpty) {
        debugPrint("Network error, falling back to cache: ${e.message}");
        return cachedReels;
      }
      
      throw Exception('Failed to fetch videos from Firestore: ${e.message}');
    } catch (e) {
      // Try to return cached data on any error
      final sharedPreferences = await SharedPreferences.getInstance();
      final mood = sharedPreferences.getString(LocalStorageConstants.currentMoodKey) ?? 'Happy';
      final cachedReels = await ReelsCacheService.getCachedReels(mood);
      
      if (cachedReels.isNotEmpty) {
        debugPrint("Error, falling back to cache: $e");
        return cachedReels;
      }
      
      throw Exception('Unexpected error while fetching videos: $e');
    }
  }

  @override
  Future<List<ReelModel>> fetchMoreVideos() async {
    if (_lastDocument == null) {
      return [];
    }

    try {
      final moreVideos = await _fetchVideosHelper(startAfterDocument: _lastDocument);
      debugPrint("MoreVideos from VideoFeedRepo: ${moreVideos.length}");
      // Cache the additional videos
      if (moreVideos.isNotEmpty) {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        String mood = sharedPreferences.getString(LocalStorageConstants.currentMoodKey) ?? 'Happy';
        await ReelsCacheService.cacheReels(moreVideos, mood);
      }
      
      return moreVideos;
    } on FirebaseException catch (e) {
      throw Exception(
        'Failed to fetch more videos from FireStore: ${e.message}',
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
      debugPrint("Mood received while fetching the reels: $mood");
      
      // Increase limit to 5 for better initial experience
      Query query =
          _reelsColRef.where("moodTag", isEqualTo: mood)
          .orderBy('createdAt', descending: true).limit(5);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      final snapshot = await query.get();

      debugPrint("Reels received for mood $mood are ${snapshot.docs.length}");
      if (snapshot.docs.isEmpty) {
        return [];
      }

      _lastDocument = snapshot.docs.last;
      final reels = snapshot.docs.map((doc)=> ReelModel.fromMap(doc.data() as Map<String,dynamic>)).toList();
      
      // Pre-cache video files in background
      _preCacheVideoFiles(reels);
      
      return reels;
    } on FirebaseException catch (e) {
      throw Exception('Firestore error while fetching videos: ${e.message}');
    } catch (e) {
      throw Exception('Error processing video data: $e');
    }
  }
  
  /// Pre-cache video files in the background
  Future<void> _preCacheVideoFiles(List<ReelModel> reels) async {
    // Don't await this to avoid blocking the UI
    for (final reel in reels) {
      ReelsCacheService.preCacheVideo(reel.videoUrl).catchError((e) {
        debugPrint('Error pre-caching video ${reel.reelID}: $e');
      });
    }
  }
}
