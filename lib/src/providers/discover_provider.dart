import 'package:flutter/material.dart';

import '../models/hashtag_model.dart';
import '../models/mood_model.dart';
import '../services/hashtag_service.dart';

class DiscoverProvider extends ChangeNotifier {
  List<HashtagModel> _trendingHashtags = [];
  List<MoodModel> _trendingMoods = [];

  bool isLoadingHashtags = true;
  bool isLoadingMoods = true;

  List<HashtagModel> get trendingHashtags => _trendingHashtags;
  List<MoodModel> get trendingMoods => _trendingMoods;

  Future<void> fetchTrendingHashtags() async {
    isLoadingHashtags = true;
    notifyListeners();
    _trendingHashtags = await HashtagService.getTrendingHashtags();
    isLoadingHashtags = false;
    notifyListeners();
  }

  Future<void> fetchTrendingMoods() async {
    isLoadingMoods = true;
    notifyListeners();
    _trendingMoods = await HashtagService.getTrendingMoods();
    isLoadingMoods = false;
    notifyListeners();
  }

  Future<void> loadAll() async {
    await Future.wait([
      fetchTrendingHashtags(),
      fetchTrendingMoods(),
    ]);
  }
}