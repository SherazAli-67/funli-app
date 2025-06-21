import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/hashtag_model.dart';
import '../models/mood_model.dart';
import '../models/reel_model.dart';
import '../services/hashtag_mood_cached_reels.dart';
import '../services/hashtag_service.dart';
import '../services/mood_service.dart';

class DiscoverProvider extends ChangeNotifier {
  List<HashtagModel> _trendingHashtags = [];
  List<MoodModel> _trendingMoods = [];
  Map<String, List<ReelModel>> _moodReels = {};
  Map<String, DocumentSnapshot?> _moodLastDocuments = {};

  bool isLoadingHashtags = true;
  bool isLoadingMoods = true;

  List<HashtagModel> get trendingHashtags => _trendingHashtags;
  List<MoodModel> get trendingMoods => _trendingMoods;
  Map<String, List<ReelModel>> get moodReels => _moodReels;
  Map<String, DocumentSnapshot?> get moodLastDocuments => _moodLastDocuments;

  Future<void> fetchTrendingHashtags() async {
    isLoadingHashtags = true;
    notifyListeners();
    _trendingHashtags = await HashtagService.getTrendingHashtags();
    debugPrint("Trending hashtags: ${trendingMoods.length}");
    isLoadingHashtags = false;
    notifyListeners();
  }

  /*Future<void> fetchTrendingMoods() async {
    isLoadingMoods = true;
    notifyListeners();
    _trendingMoods = await HashtagService.getTrendingMoods();
    // Preload reels for each mood
    for (var mood in _trendingMoods) {
      var data = await MoodService.getReelsByMood(mood: mood.mood);
      _moodReels[mood.mood] = data['reels'];
      _moodLastDocuments[mood.mood] = data['lastDocument'];
    }
    isLoadingMoods = false;
    notifyListeners();
  }*/

  Future<void> fetchTrendingMoods() async {
    isLoadingMoods = true;
    notifyListeners();
    _trendingMoods = await HashtagService.getTrendingMoods();
    // Check if we should refresh from network
    bool shouldRefresh = await HashtagMoodCachedReels.shouldRefreshFromNetwork();

    // Preload reels for each mood
    for (var mood in _trendingMoods) {
      if (shouldRefresh) {
        var data = await MoodService.getReelsByMood(mood: mood.mood);
        _moodReels[mood.mood] = data['reels'];
        _moodLastDocuments[mood.mood] = data['lastDocument'];
        // Cache the reels
        await HashtagMoodCachedReels.cacheReels(data['reels'], mood.mood, data['lastDocument']);
      } else {
        // Use cached data
        _moodReels[mood.mood] = await HashtagMoodCachedReels.getCachedReels(mood.mood);
        _moodLastDocuments[mood.mood] = await HashtagMoodCachedReels.getCachedLastDocument(mood.mood);
      }
      notifyListeners();
    }
    isLoadingMoods = false;
    notifyListeners();
  }

  Future<void> loadAll() async {
    debugPrint("Loading moods and tags reels");
    await Future.wait([
      fetchTrendingHashtags(),
      fetchTrendingMoods(),
    ]);
  }
}
