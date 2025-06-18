import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service to handle persistent caching of reels data and files
class ReelsCacheService {
  static const String _cacheKey = 'cached_reels_data';
  static const String _lastFetchTimeKey = 'last_reels_fetch_time';
  static const String _currentMoodKey = 'current_mood_key';
  
  // Custom cache manager with longer cache duration
  static final CacheManager customCacheManager = CacheManager(
    Config(
      'reels_cache',
      stalePeriod: const Duration(days: 7), // Keep videos for 7 days
      maxNrOfCacheObjects: 100, // Store up to 100 videos
      repo: JsonCacheInfoRepository(databaseName: 'reels_cache_db'),
      fileService: HttpFileService(),
    ),
  );

  /// Save reels to persistent cache
  static Future<void> cacheReels(List<ReelModel> reels, String mood) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing cached reels
      final cachedReelsJson = prefs.getString(_cacheKey) ?? '{}';
      final Map<String, dynamic> cachedReelsMap = json.decode(cachedReelsJson);
      
      // Get or create mood-specific cache
      if (!cachedReelsMap.containsKey(mood)) {
        cachedReelsMap[mood] = [];
      }
      
      // Convert reels to JSON
      final List<Map<String, dynamic>> reelsJson = reels.map((reel) => reel.toMap()).toList();
      
      // Update cache with new reels, avoiding duplicates
      final List<dynamic> existingReels = List.from(cachedReelsMap[mood]);
      final Set<String> existingIds = existingReels
          .map((reel) => reel['reelID'] as String)
          .toSet();
      
      for (final reelJson in reelsJson) {
        if (!existingIds.contains(reelJson['reelID'])) {
          existingReels.add(reelJson);
          existingIds.add(reelJson['reelID']);
        }
      }
      
      // Sort by createdAt (newest first)
      existingReels.sort((a, b) {
        final DateTime dateA = DateTime.parse(a['createdAt'].toString());
        final DateTime dateB = DateTime.parse(b['createdAt'].toString());
        return dateB.compareTo(dateA);
      });
      
      // Limit cache size to 50 reels per mood
      if (existingReels.length > 50) {
        existingReels.removeRange(50, existingReels.length);
      }
      
      cachedReelsMap[mood] = existingReels;
      
      // Save updated cache
      await prefs.setString(_cacheKey, json.encode(cachedReelsMap));
      
      // Update last fetch time
      await prefs.setInt(_lastFetchTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      debugPrint('Cached ${reels.length} reels for mood: $mood');
    } catch (e) {
      debugPrint('Error caching reels: $e');
    }
  }

  /// Get cached reels for a specific mood
  static Future<List<ReelModel>> getCachedReels(String mood) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedReelsJson = prefs.getString(_cacheKey) ?? '{}';
      final Map<String, dynamic> cachedReelsMap = json.decode(cachedReelsJson);
      
      if (!cachedReelsMap.containsKey(mood)) {
        return [];
      }
      
      final List<dynamic> reelsJson = cachedReelsMap[mood];
      return reelsJson.map((json) => 
        ReelModel.fromMap(Map<String, dynamic>.from(json))
      ).toList();
    } catch (e) {
      debugPrint('Error getting cached reels: $e');
      return [];
    }
  }

  /// Check if we should refresh from network based on time since last fetch
  static Future<bool> shouldRefreshFromNetwork() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchTime = prefs.getInt(_lastFetchTimeKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Refresh if last fetch was more than 30 minutes ago
      return (now - lastFetchTime) > 30 * 60 * 1000;
    } catch (e) {
      return true;
    }
  }

  /// Get current mood from cache
  static Future<String> getCurrentMood() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_currentMoodKey) ?? 'Happy';
    } catch (e) {
      return 'Happy';
    }
  }

  /// Pre-cache a video file to ensure it's available offline
  static Future<File> preCacheVideo(String url) async {
    try {
      final fileInfo = await customCacheManager.getFileFromCache(url);
      if (fileInfo != null) {
        return fileInfo.file;
      }
      
      // Download and cache the file
      final file = await customCacheManager.getSingleFile(url);
      return file;
    } catch (e) {
      debugPrint('Error pre-caching video: $e');
      rethrow;
    }
  }

  /// Get a cached video file
  static Future<File?> getCachedVideo(String url) async {
    try {
      final fileInfo = await customCacheManager.getFileFromCache(url);
      return fileInfo?.file;
    } catch (e) {
      debugPrint('Error getting cached video: $e');
      return null;
    }
  }

  /// Clear all cached data (for testing or user-initiated cache clearing)
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastFetchTimeKey);
      await customCacheManager.emptyCache();
      debugPrint('Cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
