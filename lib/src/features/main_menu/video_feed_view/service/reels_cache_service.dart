import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart' show unawaited;

/// A service to handle persistent caching of reels data and files
class ReelsCacheService {
  static const String _cacheKey = 'cached_reels_data';
  static const String _lastFetchTimeKey = 'last_reels_fetch_time';
  static const String _currentMoodKey = 'current_mood_key';
  static const String _preloadedMoodsKey = 'preloaded_moods_key';
  
  // In-memory cache for faster access
  static final Map<String, File> _memoryCache = {};
  
  // Track ongoing downloads to prevent duplicate requests
  static final Map<String, Completer<File>> _activeDownloads = {};
  
  // Custom cache manager with longer cache duration
  static final CacheManager customCacheManager = CacheManager(
    Config(
      'reels_cache',
      stalePeriod: const Duration(days: 14), // Keep videos for 14 days (increased)
      maxNrOfCacheObjects: 200, // Store up to 200 videos (increased)
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
      
      // Increased cache size to 100 reels per mood for better experience
      if (existingReels.length > 100) {
        existingReels.removeRange(100, existingReels.length);
      }
      
      cachedReelsMap[mood] = existingReels;
      
      // Save updated cache
      await prefs.setString(_cacheKey, json.encode(cachedReelsMap));
      
      // Update last fetch time
      await prefs.setInt(_lastFetchTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      // Add to preloaded moods set
      final preloadedMoods = prefs.getStringList(_preloadedMoodsKey) ?? [];
      if (!preloadedMoods.contains(mood)) {
        preloadedMoods.add(mood);
        await prefs.setStringList(_preloadedMoodsKey, preloadedMoods);
      }
      
      debugPrint('Cached ${reels.length} reels for mood: $mood');
      
      // Start preloading videos for this mood in the background
      _preloadVideosForMood(reels);
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
      final reels = reelsJson.map((json) => 
        ReelModel.fromMap(Map<String, dynamic>.from(json))
      ).toList();
      
      // Start preloading videos for this mood in the background
      // This ensures videos are ready when user starts viewing
      _preloadVideosForMood(reels);
      
      return reels;
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
      
      // Refresh if last fetch was more than 15 minutes ago (reduced from 30)
      // This ensures more frequent updates for fresher content
      return (now - lastFetchTime) > 15 * 60 * 1000;
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

  /// Preload videos for a specific mood in the background
  static Future<void> _preloadVideosForMood(List<ReelModel> reels) async {
    // Limit to first 5 videos to avoid excessive network usage
    final videosToPreload = reels.take(5).toList();
    
    for (final reel in videosToPreload) {
      try {
        // Don't await to allow parallel downloads
        unawaited(preCacheVideo(reel.videoUrl));
      } catch (e) {
        // Silently handle errors for background preloading
        debugPrint('Background preload error: $e');
      }
    }
  }

  /// Custom HTTP client that accepts 206 Partial Content as valid response
  static Future<http.Response> _httpGet(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      // Accept 200 OK and 206 Partial Content as valid responses
      if (response.statusCode == 200 || response.statusCode == 206) {
        return response;
      } else {
        throw HttpException('Invalid statusCode: ${response.statusCode}, uri = $url');
      }
    } catch (e) {
      throw HttpException('Failed to download: $e, uri = $url');
    }
  }

  /// Pre-cache a video file to ensure it's available offline
  static Future<File> preCacheVideo(String url) async {
    // Check memory cache first for instant access
    if (_memoryCache.containsKey(url)) {
      final file = _memoryCache[url]!;
      if (await file.exists()) {
        return file;
      } else {
        // Remove invalid file from memory cache
        _memoryCache.remove(url);
      }
    }
    
    // Check if download is already in progress
    if (_activeDownloads.containsKey(url)) {
      return _activeDownloads[url]!.future;
    }
    
    // Create a new completer for this download
    final completer = Completer<File>();
    _activeDownloads[url] = completer;
    
    try {
      // First check if file is already in cache
      final fileInfo = await customCacheManager.getFileFromCache(url);
      if (fileInfo != null) {
        final file = fileInfo.file;
        // Add to memory cache
        _memoryCache[url] = file;
        completer.complete(file);
        _activeDownloads.remove(url);
        return file;
      }
      
      // Try using the cache manager first
      try {
        final file = await customCacheManager.getSingleFile(
          url,
          // Use a custom HTTP getter that accepts 206 responses
          // withProgress: true,
        );
        
        // Add to memory cache
        _memoryCache[url] = file;
        completer.complete(file);
        _activeDownloads.remove(url);
        return file;
      } catch (cacheError) {
        // If cache manager fails, try direct download
        debugPrint('Cache manager failed, trying direct download: $cacheError');
        
        final tempDir = await getTemporaryDirectory();
        final fileName = url.split('/').last.split('?').first;
        final file = File('${tempDir.path}/$fileName');
        
        // Download the file directly
        final response = await _httpGet(url);
        await file.writeAsBytes(response.bodyBytes);
        
        // Add to memory cache
        _memoryCache[url] = file;
        completer.complete(file);
        _activeDownloads.remove(url);
        return file;
      }
    } catch (e) {
      _activeDownloads.remove(url);
      completer.completeError(e);
      debugPrint('Error pre-caching video: $e');
      
      // Create an empty file as fallback to prevent app crashes
      try {
        final tempDir = await getTemporaryDirectory();
        final fallbackFile = File('${tempDir.path}/fallback_${DateTime.now().millisecondsSinceEpoch}.mp4');
        await fallbackFile.create();
        return fallbackFile;
      } catch (fallbackError) {
        debugPrint('Error creating fallback file: $fallbackError');
        // Create a valid File object with a temporary path
        final tempDir = await getTemporaryDirectory();
        return File('${tempDir.path}/empty_fallback.mp4');
      }
    }
  }

  /// Get a cached video file
  static Future<File?> getCachedVideo(String url) async {
    // Check memory cache first for instant access
    if (_memoryCache.containsKey(url)) {
      final file = _memoryCache[url]!;
      if (await file.exists()) {
        return file;
      } else {
        // Remove invalid file from memory cache
        _memoryCache.remove(url);
      }
    }
    
    // Check if download is already in progress
    if (_activeDownloads.containsKey(url)) {
      try {
        return await _activeDownloads[url]!.future;
      } catch (e) {
        // If the active download fails, continue to check cache
        debugPrint('Active download failed, checking cache: $e');
      }
    }
    
    try {
      final fileInfo = await customCacheManager.getFileFromCache(url);
      if (fileInfo != null) {
        final file = fileInfo.file;
        // Add to memory cache for faster future access
        _memoryCache[url] = file;
        return file;
      }
      return null;
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
      await prefs.remove(_preloadedMoodsKey);
      await customCacheManager.emptyCache();
      _memoryCache.clear();
      _activeDownloads.clear();
      debugPrint('Cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
  
  /// Preload videos for all available moods
  static Future<void> preloadAllMoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preloadedMoods = prefs.getStringList(_preloadedMoodsKey) ?? [];
      
      for (final mood in preloadedMoods) {
        final reels = await getCachedReels(mood);
        if (reels.isNotEmpty) {
          // Preload first 3 videos for each mood
          for (int i = 0; i < math.min(3, reels.length); i++) {
            try {
              // Don't await to allow parallel downloads
              unawaited(preCacheVideo(reels[i].videoUrl));
            } catch (e) {
              // Silently handle errors for background preloading
              debugPrint('Background mood preload error: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error preloading moods: $e');
    }
  }
  
  /// Remove a specific reel from cache by its video URL
  static Future<void> removeCachedReel(String videoUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedReelsJson = prefs.getString(_cacheKey) ?? '{}';
      final Map<String, dynamic> cachedReelsMap = json.decode(cachedReelsJson);
      
      // Iterate through all moods to find and remove the reel
      for (final mood in cachedReelsMap.keys) {
        final List<dynamic> reels = cachedReelsMap[mood];
        reels.removeWhere((reel) => reel['videoUrl'] == videoUrl);
        cachedReelsMap[mood] = reels;
      }
      
      // Save updated cache
      await prefs.setString(_cacheKey, json.encode(cachedReelsMap));
      
      // Also remove from memory cache if it exists
      _memoryCache.remove(videoUrl);
      
      // Remove from active downloads if it exists
      _activeDownloads.remove(videoUrl);
      
      // Optionally, remove the file from the cache manager if needed
      try {
        await customCacheManager.removeFile(videoUrl);
      } catch (e) {
        debugPrint('Error removing file from cache manager: $e');
      }
      
      debugPrint('Removed reel from cache: $videoUrl');
    } catch (e) {
      debugPrint('Error removing reel from cache: $e');
    }
  }

  /// Clean up memory cache to prevent memory leaks
  static void cleanupMemoryCache({int maxSize = 30}) {
    if (_memoryCache.length > maxSize) {
      final keysToRemove = _memoryCache.keys.take(_memoryCache.length - maxSize).toList();
      for (final key in keysToRemove) {
        _memoryCache.remove(key);
      }
    }
  }
}
