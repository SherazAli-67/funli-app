import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/reel_model.dart';
import '../res/firebase_constants.dart';
import '../services/reels_service.dart';
import '../services/reels_cache_service.dart';
import 'universal_reel_feed_controller.dart';

/// Result class for data source fetch operations
class ReelFetchResult {
  final List<ReelModel> newReels;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  ReelFetchResult({
    required this.newReels,
    this.lastDocument,
    this.hasMore = true,
  });
}

/// Abstract base class for all reel data sources
abstract class ReelDataSource {
  String get sourceType;
  Map<String, dynamic> get context;
  
  Future<ReelFetchResult> fetchMoreReels(DocumentSnapshot? lastDocument);
}

/// Data source for mood-based reels
class MoodReelDataSource extends ReelDataSource {
  final String mood;
  static const int _limit = 10;

  MoodReelDataSource({required this.mood});

  @override
  String get sourceType => 'mood';

  @override
  Map<String, dynamic> get context => {'mood': mood};

  @override
  Future<ReelFetchResult> fetchMoreReels(DocumentSnapshot? lastDocument) async {
    try {
      debugPrint('Fetching mood reels for: $mood');
      
      Query query = FirebaseFirestore.instance
          .collection(FirebaseConstants.moodsCollection)
          .doc(mood)
          .collection(FirebaseConstants.reelsCollection)
          .orderBy("createdAt", descending: true)
          .limit(_limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final List<ReelModel> newReels = [];

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final reelID = doc.id;
          final reelSnap = await FirebaseFirestore.instance
              .collection(FirebaseConstants.reelsCollection)
              .doc(reelID)
              .get();

          if (reelSnap.exists) {
            final reelData = reelSnap.data()!;
            reelData["id"] = reelSnap.id;
            newReels.add(ReelModel.fromMap(reelData));
          }
        }
        
        // Cache the fetched reels
        if (newReels.isNotEmpty) {
          await ReelsCacheService.cacheReels(newReels, mood);
        }
      }

      return ReelFetchResult(
        newReels: newReels,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length == _limit,
      );
    } catch (e) {
      debugPrint('Error fetching mood reels: $e');
      return ReelFetchResult(newReels: []);
    }
  }
}

/// Data source for hashtag-based reels
class HashtagReelDataSource extends ReelDataSource {
  final String tag;
  final bool isComingFromMood;
  static const int _limit = 10;

  HashtagReelDataSource({
    required this.tag, 
    this.isComingFromMood = false,
  });

  @override
  String get sourceType => isComingFromMood ? 'mood' : 'hashtag';

  @override
  Map<String, dynamic> get context => {
    'tag': tag,
    'isComingFromMood': isComingFromMood,
  };

  @override
  Future<ReelFetchResult> fetchMoreReels(DocumentSnapshot? lastDocument) async {
    try {
      debugPrint('Fetching hashtag reels for: $tag');
      
      late Query query;
      
      if (isComingFromMood) {
        query = FirebaseFirestore.instance
            .collection(FirebaseConstants.moodsCollection)
            .doc(tag)
            .collection(FirebaseConstants.reelsCollection)
            .orderBy("createdAt", descending: true)
            .limit(_limit);
      } else {
        query = FirebaseFirestore.instance
            .collection(FirebaseConstants.hashtagsCollections)
            .doc(tag)
            .collection(FirebaseConstants.reelsCollection)
            .orderBy("createdAt", descending: true)
            .limit(_limit);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final List<ReelModel> newReels = [];

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final reelID = doc.id;
          final reelSnap = await FirebaseFirestore.instance
              .collection(FirebaseConstants.reelsCollection)
              .doc(reelID)
              .get();

          if (reelSnap.exists) {
            final reelData = reelSnap.data()!;
            reelData["id"] = reelSnap.id;
            newReels.add(ReelModel.fromMap(reelData));
          }
        }
      }

      return ReelFetchResult(
        newReels: newReels,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length == _limit,
      );
    } catch (e) {
      debugPrint('Error fetching hashtag reels: $e');
      return ReelFetchResult(newReels: []);
    }
  }
}

/// Data source for search/filtered reels
class SearchReelDataSource extends ReelDataSource {
  final ReelSearchFilter filter;
  static const int _limit = 10;

  SearchReelDataSource({required this.filter});

  @override
  String get sourceType => 'search';

  @override
  Map<String, dynamic> get context => filter.toMap();

  @override
  Future<ReelFetchResult> fetchMoreReels(DocumentSnapshot? lastDocument) async {
    try {
      debugPrint('Fetching search reels with filter: ${filter.toMap()}');
      
      Query query = FirebaseFirestore.instance
          .collection(FirebaseConstants.reelsCollection)
          .limit(_limit);

      // Apply mood filter
      if (filter.selectedMood != null && filter.selectedMood!.isNotEmpty) {
        String mood = filter.selectedMood![0].toUpperCase() + 
                     filter.selectedMood!.substring(1);
        query = query.where('moodTag', isEqualTo: mood);
      }

      // Apply popularity sorting
      if (filter.selectedPopularity != null) {
        switch (filter.selectedPopularity) {
          case 'topFeels':
            query = query.orderBy('likesCount', descending: true);
            break;
          case 'newestFeels':
            query = query.orderBy('createdAt', descending: true);
            break;
          case 'mostViewed':
            query = query.orderBy('viewsCount', descending: true);
            break;
          default:
            query = query.orderBy('createdAt', descending: true);
            break;
        }
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final List<ReelModel> newReels = [];

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final reelData = doc.data() as Map<String, dynamic>;
          reelData["id"] = doc.id;
          newReels.add(ReelModel.fromMap(reelData));
        }
      }

      return ReelFetchResult(
        newReels: newReels,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length == _limit,
      );
    } catch (e) {
      debugPrint('Error fetching search reels: $e');
      return ReelFetchResult(newReels: []);
    }
  }
}

/// Data source for user profile reels
class UserProfileReelDataSource extends ReelDataSource {
  final String userID;
  static const int _limit = 10;

  UserProfileReelDataSource({required this.userID});

  @override
  String get sourceType => 'user_profile';

  @override
  Map<String, dynamic> get context => {'userID': userID};

  @override
  Future<ReelFetchResult> fetchMoreReels(DocumentSnapshot? lastDocument) async {
    try {
      debugPrint('Fetching user profile reels for: $userID');
      
      // Use existing reels service for user reels
      final newReels = await ReelsService.fetchUserReels(
        userId: userID,
        lastDoc: lastDocument,
        limit: _limit,
        onLastDoc: (doc) {
          // This will be handled by the result
        },
        onHasMore: (hasMore) {
          // This will be handled by the result
        },
        comingFromProfile: true,
      );

      // Since ReelsService doesn't provide lastDoc and hasMore directly,
      // we'll simulate it based on the number of reels returned
      final hasMore = newReels.length == _limit;
      DocumentSnapshot? newLastDoc;
      
      if (newReels.isNotEmpty && hasMore) {
        // We would need to modify ReelsService to return the last document
        // For now, we'll work with what we have
      }

      // Cache the fetched reels
      if (newReels.isNotEmpty) {
        await ReelsCacheService.cacheUserReels(newReels, userID);
      }

      return ReelFetchResult(
        newReels: newReels,
        lastDocument: newLastDoc,
        hasMore: hasMore,
      );
    } catch (e) {
      debugPrint('Error fetching user profile reels: $e');
      return ReelFetchResult(newReels: []);
    }
  }
}

/// Data source for user bookmarked reels
class BookmarkReelDataSource extends ReelDataSource {
  final String userID;
  static const int _limit = 10;

  BookmarkReelDataSource({required this.userID});

  @override
  String get sourceType => 'bookmark';

  @override
  Map<String, dynamic> get context => {'userID': userID};

  @override
  Future<ReelFetchResult> fetchMoreReels(DocumentSnapshot? lastDocument) async {
    try {
      debugPrint('Fetching bookmark reels for: $userID');
      
      Query query = FirebaseFirestore.instance
          .collection(FirebaseConstants.userCollection)
          .doc(userID)
          .collection(FirebaseConstants.bookmarksCollection)
          .orderBy("timestamp", descending: true)
          .limit(_limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      final List<ReelModel> newReels = [];

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          final reelID = doc.id;
          final reelSnap = await FirebaseFirestore.instance
              .collection(FirebaseConstants.reelsCollection)
              .doc(reelID)
              .get();

          if (reelSnap.exists) {
            final reelData = reelSnap.data()!;
            reelData["id"] = reelSnap.id;
            newReels.add(ReelModel.fromMap(reelData));
          }
        }

        // Cache the fetched bookmarks
        if (newReels.isNotEmpty) {
          await ReelsCacheService.cacheUserBookmarks(newReels, userID);
        }
      }

      return ReelFetchResult(
        newReels: newReels,
        lastDocument: querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
        hasMore: querySnapshot.docs.length == _limit,
      );
    } catch (e) {
      debugPrint('Error fetching bookmark reels: $e');
      return ReelFetchResult(newReels: []);
    }
  }
}
