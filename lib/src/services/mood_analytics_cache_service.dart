import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:funli_app/src/services/settings_service.dart';
import 'package:funli_app/src/features/profile_analytics_dashboard/reel_views_chart.dart';

class MoodAnalyticsCacheService {
  static const String _moodAnalyticsKey = 'mood_analytics';
  static const String _moodPercentagesKey = 'mood_percentages';
  static const String _moodStreaksKey = 'mood_streaks';
  static const String _lastUpdatedKey = 'last_updated';
  static const int _cacheDurationHours = 24; // Cache data for 24 hours

  /// Get cached mood analytics or fetch from server if cache is outdated
  static Future<String> getUserMoodAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_moodAnalyticsKey);
    final lastUpdatedStr = prefs.getString(_lastUpdatedKey);

    if (cachedData != null && lastUpdatedStr != null) {
      final lastUpdated = DateTime.tryParse(lastUpdatedStr);
      if (lastUpdated != null &&
          DateTime.now().difference(lastUpdated).inHours < _cacheDurationHours) {
        return cachedData;
      }
    }

    // Fetch from server if no cache or cache is outdated
    final data = await SettingsService.getUserMoodAnalytics();
    await prefs.setString(_moodAnalyticsKey, data);
    await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
    return data;
  }

  /// Get cached mood percentages or fetch from server if cache is outdated
  static Future<Map<String, dynamic>> getMoodPercentages() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_moodPercentagesKey);
    final lastUpdatedStr = prefs.getString(_lastUpdatedKey);

    if (cachedData != null && lastUpdatedStr != null) {
      final lastUpdated = DateTime.tryParse(lastUpdatedStr);
      if (lastUpdated != null &&
          DateTime.now().difference(lastUpdated).inHours < _cacheDurationHours) {
        return jsonDecode(cachedData) as Map<String, dynamic>;
      }
    }

    // Fetch from server if no cache or cache is outdated
    final data = await SettingsService.calculateMoodPercentages();
    await prefs.setString(_moodPercentagesKey, jsonEncode(data));
    await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
    return data;
  }

  /// Get cached mood streaks or fetch from server if cache is outdated
  static Future<Map<String, int>> getMoodStreaks() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_moodStreaksKey);
    final lastUpdatedStr = prefs.getString(_lastUpdatedKey);

    if (cachedData != null && lastUpdatedStr != null) {
      final lastUpdated = DateTime.tryParse(lastUpdatedStr);
      if (lastUpdated != null &&
          DateTime.now().difference(lastUpdated).inHours < _cacheDurationHours) {
        final decoded = jsonDecode(cachedData) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, value as int));
      }
    }

    // Fetch from server if no cache or cache is outdated
    final data = await SettingsService.calculateMoodStreaks();
    await prefs.setString(_moodStreaksKey, jsonEncode(data));
    await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
    return data;
  }

  /// Force refresh the cache by fetching latest data from server
  static Future<void> refreshCache() async {
    final prefs = await SharedPreferences.getInstance();
    final moodAnalytics = await SettingsService.getUserMoodAnalytics();
    final moodPercentages = await SettingsService.calculateMoodPercentages();
    final moodStreaks = await SettingsService.calculateMoodStreaks();

    await prefs.setString(_moodAnalyticsKey, moodAnalytics);
    await prefs.setString(_moodPercentagesKey, jsonEncode(moodPercentages));
    await prefs.setString(_moodStreaksKey, jsonEncode(moodStreaks));
    await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
  }

  /// Get cached reel views data or fetch from server if cache is outdated
  static Future<List<Map<String, dynamic>>> getReelViewsData(TimeRange timeRange) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'reel_views_${timeRange.toString().split('.').last}';
    final cachedData = prefs.getString(cacheKey);
    final lastUpdatedStr = prefs.getString(_lastUpdatedKey);

    if (cachedData != null && lastUpdatedStr != null) {
      final lastUpdated = DateTime.tryParse(lastUpdatedStr);
      if (lastUpdated != null &&
          DateTime.now().difference(lastUpdated).inHours < _cacheDurationHours) {
        return List<Map<String, dynamic>>.from(jsonDecode(cachedData));
      }
    }

    // Fetch from server if no cache or cache is outdated
    final data = await SettingsService.getReelViewsData(timeRange);
    await prefs.setString(cacheKey, jsonEncode(data));
    await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
    return data;
  }
}
