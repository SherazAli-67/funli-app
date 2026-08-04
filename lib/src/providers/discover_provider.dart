import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/mood_model.dart';
import '../models/reel_model.dart';
import '../models/user_model.dart';
import '../services/hashtag_mood_cached_reels.dart';
import '../services/hashtag_service.dart';
import '../services/mood_service.dart';
import '../services/reels_service.dart';
import '../services/user_service.dart';

class DiscoverProvider extends ChangeNotifier {
  List<MoodModel> _trendingMoods = [];
  final Map<String, List<ReelModel>> _moodReels = {};
  final Map<String, DocumentSnapshot?> _moodLastDocuments = {};
  List<UserModel> _topVibeSeekers = [];
  List<ReelModel> _recentReels = [];
  DocumentSnapshot? _recentLastDocument;

  bool isLoadingMoods = true;
  bool isLoadingSeekers = true;
  bool isLoadingRecent = true;
  bool isLoadingMoreRecent = false;
  bool hasMoreRecent = true;

  List<MoodModel> get trendingMoods => _trendingMoods;
  Map<String, List<ReelModel>> get moodReels => _moodReels;
  Map<String, DocumentSnapshot?> get moodLastDocuments => _moodLastDocuments;
  List<UserModel> get topVibeSeekers => _topVibeSeekers;
  List<ReelModel> get recentReels => _recentReels;
  DocumentSnapshot? get recentLastDocument => _recentLastDocument;

  Future<void> fetchTrendingMoods() async {
    isLoadingMoods = true;
    notifyListeners();
    _trendingMoods = await HashtagService.getTrendingMoods();
    bool shouldRefresh = await HashtagMoodCachedReels.shouldRefreshFromNetwork();

    for (var mood in _trendingMoods) {
      if (shouldRefresh) {
        var data = await MoodService.getReelsByMood(mood: mood.mood);
        _moodReels[mood.mood] = data['reels'];
        _moodLastDocuments[mood.mood] = data['lastDocument'];
        await HashtagMoodCachedReels.cacheReels(
            data['reels'], mood.mood, data['lastDocument']);
      } else {
        _moodReels[mood.mood] =
            await HashtagMoodCachedReels.getCachedReels(mood.mood);
        _moodLastDocuments[mood.mood] =
            await HashtagMoodCachedReels.getCachedLastDocument(mood.mood);
      }
      notifyListeners();
    }
    isLoadingMoods = false;
    notifyListeners();
  }

  Future<void> fetchTopVibeSeekers() async {
    isLoadingSeekers = true;
    notifyListeners();
    try {
      _topVibeSeekers = await UserService.getTopUsersByReelsPosted();
    } catch (e) {
      debugPrint('Error fetching top vibe seekers: $e');
      _topVibeSeekers = [];
    }
    isLoadingSeekers = false;
    notifyListeners();
  }

  Future<void> fetchRecentReels({bool refresh = false}) async {
    if (refresh) {
      _recentReels = [];
      _recentLastDocument = null;
      hasMoreRecent = true;
      isLoadingRecent = true;
      notifyListeners();
    } else if (_recentReels.isEmpty) {
      isLoadingRecent = true;
      notifyListeners();
    }

    try {
      final reels = await ReelsService.fetchMoreReels(
        lastDoc: _recentLastDocument,
        limit: 16,
        onLastDoc: (doc) => _recentLastDocument = doc,
        onHasMore: (hasMore) => hasMoreRecent = hasMore,
      );
      _recentReels = reels;
    } catch (e) {
      debugPrint('Error fetching recent reels: $e');
    }
    isLoadingRecent = false;
    notifyListeners();
  }

  Future<void> loadMoreRecentReels() async {
    if (isLoadingMoreRecent || !hasMoreRecent || isLoadingRecent) return;

    isLoadingMoreRecent = true;
    notifyListeners();

    try {
      final reels = await ReelsService.fetchMoreReels(
        lastDoc: _recentLastDocument,
        limit: 16,
        onLastDoc: (doc) => _recentLastDocument = doc,
        onHasMore: (hasMore) => hasMoreRecent = hasMore,
      );
      _recentReels.addAll(reels);
    } catch (e) {
      debugPrint('Error loading more recent reels: $e');
    }
    isLoadingMoreRecent = false;
    notifyListeners();
  }

  Future<void> loadAll() async {
    await Future.wait([
      fetchTrendingMoods(),
      fetchTopVibeSeekers(),
      fetchRecentReels(refresh: true),
    ]);
  }
}
