import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../res/firebase_constants.dart';

/// A service to handle caching of reels data for hashtags and moods
class HashtagMoodCachedReels {
  static const String _cacheKey = 'cached_hashtag_mood_reels';
  static const String _lastFetchTimeKey = 'last_hashtag_mood_fetch_time';

  // In-memory cache for faster access
  static final Map<String, List<ReelModel>> _memoryCacheReels = {};
  static final Map<String, DocumentSnapshot?> _memoryCacheLastDocs = {};

  /// Save reels to persistent cache for a specific mood or hashtag
  static Future<void> cacheReels(List<ReelModel> reels, String key, DocumentSnapshot? lastDocument) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      debugPrint("${reels.length} reels added to cache for $key");
      // Get existing cached data
      final cachedDataJson = prefs.getString(_cacheKey) ?? '{}';
      final Map<String, dynamic> cachedDataMap = json.decode(cachedDataJson);
      
      // Get or create cache for the specific key (mood or hashtag)
      if (!cachedDataMap.containsKey(key)) {
        cachedDataMap[key] = {};
      }
      
      // Convert reels to JSON
      final List<Map<String, dynamic>> reelsJson = reels.map((reel) => reel.toMap()).toList();
      
      // Update cache with new reels, avoiding duplicates
      final Map<String, dynamic> keyCache = Map<String, dynamic>.from(cachedDataMap[key]);
      final List<dynamic> existingReels = keyCache.containsKey('reels') ? List.from(keyCache['reels']) : [];
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
      
      // Limit cache size to 50 reels per key
      if (existingReels.length > 50) {
        existingReels.removeRange(50, existingReels.length);
      }
      
      // Update cache entry
      keyCache['reels'] = existingReels;
      keyCache['lastDocument'] = lastDocument?.id ?? '';
      cachedDataMap[key] = keyCache;
      
      // Save updated cache
      await prefs.setString(_cacheKey, json.encode(cachedDataMap));
      
      // Update last fetch time
      await prefs.setInt(_lastFetchTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      // Update in-memory cache
      _memoryCacheReels[key] = reels;
      _memoryCacheLastDocs[key] = lastDocument;
      
      debugPrint('Cached ${reels.length} reels for key: $key');
    } catch (e) {
      debugPrint('Error caching reels: $e');
    }
  }

  /// Get cached reels for a specific mood or hashtag
  static Future<List<ReelModel>> getCachedReels(String key) async {
    try {
      // Check memory cache first
      if (_memoryCacheReels.containsKey(key)) {
        return _memoryCacheReels[key]!;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final cachedDataJson = prefs.getString(_cacheKey) ?? '{}';
      final Map<String, dynamic> cachedDataMap = json.decode(cachedDataJson);
      
      if (!cachedDataMap.containsKey(key) || !cachedDataMap[key].containsKey('reels')) {
        return [];
      }
      
      final List<dynamic> reelsJson = cachedDataMap[key]['reels'];
      final reels = reelsJson.map((json) => 
        ReelModel.fromMap(Map<String, dynamic>.from(json))
      ).toList();
      
      // Update memory cache
      _memoryCacheReels[key] = reels;
      
      return reels;
    } catch (e) {
      debugPrint('Error getting cached reels: $e');
      return [];
    }
  }

  /// Get cached last document for a specific mood or hashtag
  static Future<DocumentSnapshot?> getCachedLastDocument(String key) async {
    try {
      // Check memory cache first
      if (_memoryCacheLastDocs.containsKey(key)) {
        return _memoryCacheLastDocs[key];
      }
      
      final prefs = await SharedPreferences.getInstance();
      final cachedDataJson = prefs.getString(_cacheKey) ?? '{}';
      final Map<String, dynamic> cachedDataMap = json.decode(cachedDataJson);
      
      if (!cachedDataMap.containsKey(key) || !cachedDataMap[key].containsKey('lastDocument')) {
        return null;
      }
      
      final String lastDocId = cachedDataMap[key]['lastDocument'];
      if (lastDocId.isEmpty) {
        return null;
      }
      
      // Fetch the document if needed, though this might not be used directly
      final docSnapshot = await FirebaseFirestore.instance
          .collection(FirebaseConstants.reelsCollection)
          .doc(lastDocId)
          .get();
      
      _memoryCacheLastDocs[key] = docSnapshot.exists ? docSnapshot : null;
      return _memoryCacheLastDocs[key];
    } catch (e) {
      debugPrint('Error getting cached last document: $e');
      return null;
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

  /// Clear all cached data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastFetchTimeKey);
      _memoryCacheReels.clear();
      _memoryCacheLastDocs.clear();
      debugPrint('Hashtag and Mood reels cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
