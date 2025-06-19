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
/// Enhanced for TikTok-like performance with multi-level caching
class ReelsCacheService {
  static const String _cacheKey = 'cached_reels_data';
  static const String _lastFetchTimeKey = 'last_reels_fetch_time';
  static const String _currentMoodKey = 'current_mood_key';
  static const String _preloadedMoodsKey = 'preloaded_moods_key';
  static const String _recentMoodsKey = 'recent_moods_key';
  static const String _videoLoadStatsKey = 'video_load_stats_key';
  
  // In-memory cache for faster access - increased size for better performance
  static final Map<String, File> _memoryCache = {};
  
  // Track ongoing downloads to prevent duplicate requests
  static final Map<String, Completer<File>> _activeDownloads = {};
  
  // Track preloaded moods for faster access
  static final Set<String> _preloadedMoodsInMemory = {};
  
  // Track video load times for analytics
  static final Map<String, int> _videoLoadTimes = {};
  
  // Track failed downloads to avoid retrying repeatedly
  static final Map<String, int> _failedDownloads = {};
  
  // Maximum number of retry attempts for failed downloads
  static const int _maxRetryAttempts = 3;
  
  // Track last access time for memory cache items for better LRU management
  static final Map<String, int> _memoryCacheLastAccess = {};
  
  // Custom cache manager with longer cache duration and larger size
  static final CacheManager customCacheManager = CacheManager(
    Config(
      'reels_cache',
      stalePeriod: const Duration(days: 60), // Keep videos for 60 days (increased)
      maxNrOfCacheObjects: 800, // Store up to 800 videos (significantly increased)
      repo: JsonCacheInfoRepository(databaseName: 'reels_cache_db'),
      fileService: HttpFileService(),
    ),
  );
  
  // Secondary cache manager for high-priority videos (current mood)
  static final CacheManager priorityCacheManager = CacheManager(
    Config(
      'priority_reels_cache',
      stalePeriod: const Duration(days: 90), // Keep priority videos even longer
      maxNrOfCacheObjects: 200, // Store up to 200 priority videos
      repo: JsonCacheInfoRepository(databaseName: 'priority_reels_cache_db'),
      fileService: HttpFileService(),
    ),
  );
  
  // Dedicated cache manager for current mood videos for fastest access
  static final CacheManager currentMoodCacheManager = CacheManager(
    Config(
      'current_mood_reels_cache',
      stalePeriod: const Duration(days: 120), // Keep current mood videos longest
      maxNrOfCacheObjects: 100, // Store up to 100 current mood videos
      repo: JsonCacheInfoRepository(databaseName: 'current_mood_reels_cache_db'),
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
      
      bool hasNewReels = false;
      for (final reelJson in reelsJson) {
        if (!existingIds.contains(reelJson['reelID'])) {
          existingReels.add(reelJson);
          existingIds.add(reelJson['reelID']);
          hasNewReels = true;
        }
      }
      
      // Sort by createdAt (newest first)
      existingReels.sort((a, b) {
        final DateTime dateA = DateTime.parse(a['createdAt'].toString());
        final DateTime dateB = DateTime.parse(b['createdAt'].toString());
        return dateB.compareTo(dateA);
      });
      
      // Increased cache size to 300 reels per mood for better experience
      if (existingReels.length > 300) {
        existingReels.removeRange(300, existingReels.length);
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
      
      // Add to in-memory preloaded moods set
      _preloadedMoodsInMemory.add(mood);
      
      // Update recent moods list (LRU style)
      final recentMoods = prefs.getStringList(_recentMoodsKey) ?? [];
      recentMoods.remove(mood); // Remove if exists
      recentMoods.insert(0, mood); // Add to front
      if (recentMoods.length > 5) {
        recentMoods.removeLast(); // Keep only 5 most recent moods
      }
      await prefs.setStringList(_recentMoodsKey, recentMoods);
      
      debugPrint('Cached ${reels.length} reels for mood: $mood');
      
      // Only preload videos if we have new reels or this is the current mood
      if (hasNewReels || mood == await getCurrentMood()) {
        // Start preloading videos for this mood in the background
        _preloadVideosForMood(reels, mood);
      }
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
      _preloadVideosForMood(reels, mood);
      
      // Update recent moods list (LRU style)
      final recentMoods = prefs.getStringList(_recentMoodsKey) ?? [];
      recentMoods.remove(mood); // Remove if exists
      recentMoods.insert(0, mood); // Add to front
      if (recentMoods.length > 5) {
        recentMoods.removeLast(); // Keep only 5 most recent moods
      }
      await prefs.setStringList(_recentMoodsKey, recentMoods);
      
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
      
      // Refresh if last fetch was more than 10 minutes ago (reduced from 15)
      // This ensures more frequent updates for fresher content
      return (now - lastFetchTime) > 10 * 60 * 1000;
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
  
  /// Get recent moods from cache
  static Future<List<String>> getRecentMoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentMoodsKey) ?? ['Happy'];
    } catch (e) {
      return ['Happy'];
    }
  }

  /// Preload videos for a specific mood in the background
  static Future<void> _preloadVideosForMood(List<ReelModel> reels, String mood) async {
    // Add to in-memory preloaded moods set
    _preloadedMoodsInMemory.add(mood);
    
    // For current mood, preload more videos with higher priority
    final currentMood = await getCurrentMood();
    final isCurrentMood = mood == currentMood;
    
    // Determine how many videos to preload based on mood priority
    final videosToPreload = isCurrentMood 
        ? reels.take(15).toList()  // Current mood: preload 15 videos
        : reels.take(8).toList();  // Other moods: preload 8 videos
    
    // First preload the first few videos sequentially for immediate access
    if (isCurrentMood && videosToPreload.isNotEmpty) {
      try {
        // Preload first video with highest priority and wait for it to complete
        // This ensures at least one video is ready immediately
        final firstVideo = videosToPreload[0];
        await preCacheVideo(
          firstVideo.videoUrl,
          highPriority: true,
          usePriorityCache: true,
          useCurrentMoodCache: true
        );
        
        // Preload second and third videos with high priority but don't wait
        if (videosToPreload.length > 1) {
          unawaited(preCacheVideo(
            videosToPreload[1].videoUrl,
            highPriority: true,
            usePriorityCache: true,
            useCurrentMoodCache: true
          ));
        }
        
        if (videosToPreload.length > 2) {
          unawaited(preCacheVideo(
            videosToPreload[2].videoUrl,
            highPriority: true,
            usePriorityCache: true,
            useCurrentMoodCache: true
          ));
        }
      } catch (e) {
        debugPrint('Error preloading initial videos: $e');
      }
    }
    
    // Then preload the rest in parallel with different priorities
    for (int i = isCurrentMood ? 3 : 0; i < videosToPreload.length; i++) {
      try {
        final reel = videosToPreload[i];
        final isHighPriority = isCurrentMood && i < 8; // First 8 videos of current mood are high priority
        
        // Don't await to allow parallel downloads
        unawaited(preCacheVideo(
          reel.videoUrl, 
          highPriority: isHighPriority,
          usePriorityCache: isCurrentMood,
          useCurrentMoodCache: isCurrentMood && i < 10
        ));
      } catch (e) {
        // Silently handle errors for background preloading
        debugPrint('Background preload error: $e');
      }
    }
  }

  /// Custom HTTP client that accepts 206 Partial Content as valid response
  /// and implements retry logic for more reliable downloads
  static Future<http.Response> _httpGet(String url, {int retries = 3}) async {
    Exception? lastException;
    
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Connection': 'keep-alive',
            'Accept-Encoding': 'gzip, deflate, br',
          },
        ).timeout(const Duration(seconds: 15));
        
        // Accept 200 OK and 206 Partial Content as valid responses
        if (response.statusCode == 200 || response.statusCode == 206) {
          return response;
        } else {
          throw HttpException('Invalid statusCode: ${response.statusCode}, uri = $url');
        }
      } catch (e) {
        lastException = Exception('Download attempt ${attempt + 1} failed: $e');
        // Wait before retry with exponential backoff
        if (attempt < retries - 1) {
          await Future.delayed(Duration(milliseconds: 200 * math.pow(2, attempt).toInt()));
        }
      }
    }
    
    throw lastException ?? Exception('Failed to download after $retries attempts');
  }

  /// Pre-cache a video file to ensure it's available offline
  /// Enhanced with priority caching and performance tracking
  static Future<File> preCacheVideo(String url, {
    bool highPriority = false, 
    bool usePriorityCache = false,
    bool useCurrentMoodCache = false
  }) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    // Update last access time for memory cache management
    _memoryCacheLastAccess[url] = startTime;
    
    // Check memory cache first for instant access
    if (_memoryCache.containsKey(url)) {
      final file = _memoryCache[url]!;
      if (await file.exists()) {
        // Track load time for analytics
        final endTime = DateTime.now().millisecondsSinceEpoch;
        _videoLoadTimes[url] = endTime - startTime;
        
        return file;
      } else {
        // Remove invalid file from memory cache
        _memoryCache.remove(url);
        _memoryCacheLastAccess.remove(url);
      }
    }
    
    // Check if download is already in progress
    if (_activeDownloads.containsKey(url)) {
      try {
        final file = await _activeDownloads[url]!.future;
        
        // Track load time for analytics
        final endTime = DateTime.now().millisecondsSinceEpoch;
        _videoLoadTimes[url] = endTime - startTime;
        
        return file;
      } catch (e) {
        // If the active download fails, continue to check cache
        _activeDownloads.remove(url);
        debugPrint('Active download failed, checking cache: $e');
      }
    }
    
    // Check if this URL has failed too many times
    if (_failedDownloads.containsKey(url) && _failedDownloads[url]! >= _maxRetryAttempts) {
      debugPrint('Skipping download for $url - too many failures');
      // Create a fallback file
      final tempDir = await getTemporaryDirectory();
      final fallbackFile = File('${tempDir.path}/fallback_${DateTime.now().millisecondsSinceEpoch}.mp4');
      try {
        await fallbackFile.create();
      } catch (e) {
        // Ignore errors when creating fallback file
      }
      return fallbackFile;
    }
    
    // Create a new completer for this download
    final completer = Completer<File>();
    _activeDownloads[url] = completer;
    
    try {
      // Choose the appropriate cache manager based on priority
      CacheManager cacheManager;
      if (useCurrentMoodCache) {
        cacheManager = currentMoodCacheManager;
      } else if (usePriorityCache) {
        cacheManager = priorityCacheManager;
      } else {
        cacheManager = customCacheManager;
      }
      
      // First check if file is already in any cache (try all cache managers)
      FileInfo? fileInfo;
      
      // Try current mood cache first for fastest access
      if (fileInfo == null) {
        try {
          fileInfo = await currentMoodCacheManager.getFileFromCache(url);
        } catch (e) {
          // Ignore errors and try next cache
        }
      }
      
      // Then try priority cache
      if (fileInfo == null) {
        try {
          fileInfo = await priorityCacheManager.getFileFromCache(url);
        } catch (e) {
          // Ignore errors and try next cache
        }
      }
      
      // Finally try regular cache
      if (fileInfo == null) {
        try {
          fileInfo = await customCacheManager.getFileFromCache(url);
        } catch (e) {
          // Ignore errors and continue
        }
      }
      
      if (fileInfo != null) {
        final file = fileInfo.file;
        // Add to memory cache
        _memoryCache[url] = file;
        _memoryCacheLastAccess[url] = startTime;
        
        // Track load time for analytics
        final endTime = DateTime.now().millisecondsSinceEpoch;
        _videoLoadTimes[url] = endTime - startTime;
        
        // Reset failed download count if it exists
        _failedDownloads.remove(url);
        
        completer.complete(file);
        _activeDownloads.remove(url);
        return file;
      }
      
      // Try using the cache manager with priority
      try {
        final file = await cacheManager.getSingleFile(
          url,
          // Use a custom HTTP getter that accepts 206 responses
          // withProgress: true,
        );
        
        // Add to memory cache
        _memoryCache[url] = file;
        _memoryCacheLastAccess[url] = startTime;
        
        // Track load time for analytics
        final endTime = DateTime.now().millisecondsSinceEpoch;
        _videoLoadTimes[url] = endTime - startTime;
        
        // Reset failed download count if it exists
        _failedDownloads.remove(url);
        
        completer.complete(file);
        _activeDownloads.remove(url);
        
        // If this is a high priority video, also store it in the current mood cache
        // This ensures it's available in multiple caches for faster access
        if (highPriority && !useCurrentMoodCache) {
          try {
            unawaited(currentMoodCacheManager.putFile(
              url,
              await file.readAsBytes(),
              maxAge: const Duration(days: 120),
              fileExtension: 'mp4'
            ));
          } catch (e) {
            // Ignore errors when storing in additional cache
          }
        }
        
        return file;
      } catch (cacheError) {
        // If cache manager fails, try direct download
        debugPrint('Cache manager failed, trying direct download: $cacheError');
        
        final tempDir = await getTemporaryDirectory();
        final fileName = url.split('/').last.split('?').first;
        final file = File('${tempDir.path}/$fileName');
        
        // Download the file directly with retry logic
        final response = await _httpGet(url, retries: 3);
        await file.writeAsBytes(response.bodyBytes);
        
        // Add to memory cache
        _memoryCache[url] = file;
        _memoryCacheLastAccess[url] = startTime;
        
        // Track load time for analytics
        final endTime = DateTime.now().millisecondsSinceEpoch;
        _videoLoadTimes[url] = endTime - startTime;
        
        // Reset failed download count if it exists
        _failedDownloads.remove(url);
        
        completer.complete(file);
        _activeDownloads.remove(url);
        
        // Also store in the appropriate cache manager for future use
        try {
          unawaited(cacheManager.putFile(
            url,
            await file.readAsBytes(),
            maxAge: useCurrentMoodCache ? const Duration(days: 120) : 
                   usePriorityCache ? const Duration(days: 90) : 
                   const Duration(days: 60),
            fileExtension: 'mp4'
          ));
        } catch (e) {
          // Ignore errors when storing in cache
        }
        
        return file;
      }
    } catch (e) {
      _activeDownloads.remove(url);
      completer.completeError(e);
      debugPrint('Error pre-caching video: $e');
      
      // Track failed download
      _failedDownloads[url] = (_failedDownloads[url] ?? 0) + 1;
      
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

  /// Get a cached video file with enhanced performance tracking
  static Future<File?> getCachedVideo(String url) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    
    // Check memory cache first for instant access
    if (_memoryCache.containsKey(url)) {
      final file = _memoryCache[url]!;
      if (await file.exists()) {
        // Track load time for analytics
        final endTime = DateTime.now().millisecondsSinceEpoch;
        _videoLoadTimes[url] = endTime - startTime;
        
        return file;
      } else {
        // Remove invalid file from memory cache
        _memoryCache.remove(url);
      }
    }
    
    // Check if download is already in progress
    if (_activeDownloads.containsKey(url)) {
      try {
        final file = await _activeDownloads[url]!.future;
        
        // Track load time for analytics
        final endTime = DateTime.now().millisecondsSinceEpoch;
        _videoLoadTimes[url] = endTime - startTime;
        
        return file;
      } catch (e) {
        // If the active download fails, continue to check cache
        debugPrint('Active download failed, checking cache: $e');
      }
    }
    
    try {
      // Check priority cache first
      FileInfo? fileInfo = await priorityCacheManager.getFileFromCache(url);
      
      // If not in priority cache, check regular cache
      if (fileInfo == null) {
        fileInfo = await customCacheManager.getFileFromCache(url);
      }
      
      if (fileInfo != null) {
        final file = fileInfo.file;
        // Add to memory cache for faster future access
        _memoryCache[url] = file;
        
        // Track load time for analytics
        final endTime = DateTime.now().millisecondsSinceEpoch;
        _videoLoadTimes[url] = endTime - startTime;
        
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
      await prefs.remove(_recentMoodsKey);
      await customCacheManager.emptyCache();
      await priorityCacheManager.emptyCache();
      _memoryCache.clear();
      _activeDownloads.clear();
      _preloadedMoodsInMemory.clear();
      _videoLoadTimes.clear();
      debugPrint('Cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
  
  /// Preload videos for all available moods
  static Future<void> preloadAllMoods() async {
    try {
      // First preload recent moods
      final recentMoods = await getRecentMoods();
      for (final mood in recentMoods) {
        final reels = await getCachedReels(mood);
        if (reels.isNotEmpty) {
          // Preload first 5 videos for recent moods
          for (int i = 0; i < math.min(5, reels.length); i++) {
            try {
              // Don't await to allow parallel downloads
              unawaited(preCacheVideo(
                reels[i].videoUrl,
                highPriority: i < 2, // First 2 videos are high priority
                usePriorityCache: i < 3, // First 3 videos use priority cache
              ));
            } catch (e) {
              // Silently handle errors for background preloading
              debugPrint('Background mood preload error: $e');
            }
          }
        }
      }
      
      // Then preload other moods
      final prefs = await SharedPreferences.getInstance();
      final preloadedMoods = prefs.getStringList(_preloadedMoodsKey) ?? [];
      
      for (final mood in preloadedMoods) {
        // Skip already preloaded moods
        if (recentMoods.contains(mood) || _preloadedMoodsInMemory.contains(mood)) {
          continue;
        }
        
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
  
  /// Preload videos for adjacent moods
  /// This is useful when user is likely to switch moods
  static Future<void> preloadAdjacentMoods() async {
    try {
      final currentMood = await getCurrentMood();
      final prefs = await SharedPreferences.getInstance();
      final preloadedMoods = prefs.getStringList(_preloadedMoodsKey) ?? [];
      
      // Get a list of moods to preload (excluding current mood)
      final moodsToPreload = preloadedMoods
          .where((mood) => mood != currentMood)
          .take(3) // Limit to 3 adjacent moods
          .toList();
      
      for (final mood in moodsToPreload) {
        final reels = await getCachedReels(mood);
        if (reels.isNotEmpty) {
          // Preload first 3 videos for each adjacent mood
          for (int i = 0; i < math.min(3, reels.length); i++) {
            try {
              // Don't await to allow parallel downloads
              unawaited(preCacheVideo(reels[i].videoUrl));
            } catch (e) {
              // Silently handle errors for background preloading
              debugPrint('Adjacent mood preload error: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error preloading adjacent moods: $e');
    }
  }
  
  /// Clean up memory cache to prevent memory leaks
  static void cleanupMemoryCache({int maxSize = 50}) {
    if (_memoryCache.length > maxSize) {
      final keysToRemove = _memoryCache.keys.take(_memoryCache.length - maxSize).toList();
      for (final key in keysToRemove) {
        _memoryCache.remove(key);
      }
    }
  }
  
  /// Get video load time statistics
  static Map<String, int> getVideoLoadTimes() {
    return Map.from(_videoLoadTimes);
  }
  
  /// Get average video load time
  static double getAverageLoadTime() {
    if (_videoLoadTimes.isEmpty) return 0;
    
    final total = _videoLoadTimes.values.reduce((a, b) => a + b);
    return total / _videoLoadTimes.length;
  }
}
