import 'dart:io';
import 'dart:collection';
import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:funli_app/src/features/main_menu/video_feed_view/bloc_cubit/video_feed_state.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/local_storage_constants.dart';
import 'package:funli_app/src/services/reels_cache_service.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repository/i_video_feed_repository.dart';
class VideoFeedCubit extends Cubit<VideoFeedState> {
  VideoFeedCubit(this.videoRepository) : super(VideoFeedState.initial());

  final IVideoFeedRepository videoRepository;
  final _preloadQueue = Queue<String>();
  final _preloadedFiles = <String, File>{};
  bool _isPreloadingMore = false;
  bool _isRefreshingInBackground = false;
  Timer? _backgroundRefreshTimer;
  Timer? _preloadDelayTimer;

  // Track last access time for preloaded files for better LRU management
  final Map<String, int> _preloadedFilesLastAccess = {};

  // Maximum number of files to keep in memory
  final int _maxMemoryCacheSize = 30;

  /// Initialize videos with optimized loading strategy
  Future<void> _initializeVideos() async {
    // First load cached videos immediately
    await _loadCachedVideosFirst();

    // Then start background refresh timer
    _startBackgroundRefreshTimer();

    // Preload all moods in the background for smoother mood switching
    ReelsCacheService.preloadAllMoods();
  }

  /// Start a timer to periodically refresh videos in the background
  void _startBackgroundRefreshTimer() {
    _backgroundRefreshTimer?.cancel();
    _backgroundRefreshTimer = Timer.periodic(
      const Duration(minutes: 5), // Reduced to 5 minutes for fresher content
          (_) => _refreshVideosInBackground(),
    );
  }

  /// Load cached videos first for immediate display
  Future<void> _loadCachedVideosFirst() async {
    try {
      // Get current mood
      final prefs = await SharedPreferences.getInstance();
      final mood = prefs.getString(LocalStorageConstants.currentMoodKey) ?? 'Happy';

      // Get cached reels for this mood
      final cachedReels = await ReelsCacheService.getCachedReels(mood);

      if (cachedReels.isNotEmpty) {
        String currentUID = FirebaseAuth.instance.currentUser!.uid;
        cachedReels.removeWhere((video)=> video.reportedByUsers.contains(currentUID));

        emit(
          state.copyWith(
            isLoading: false,
            videos: cachedReels,
            hasMoreVideos: true,
            currentVideoIndex: 0,
            loadingSource: 'cache',
          ),
        );

        // Start preloading next videos
        preloadNextVideos();

        // Then refresh from network in background
        _refreshVideosInBackground();
      } else {
        // If no cached reels, attempt a fast initial fetch for new users
        emit(
          state.copyWith(
            isLoading: true,
            loadingSource: 'network_initial',
          ),
        );
        try {
          // Fetch a small batch of reels quickly for new users
          final initialReels = await videoRepository.fetchVideos(limit: cachedReels.isEmpty ? 5 : 3);
          if (initialReels.isNotEmpty) {
            emit(
              state.copyWith(
                isLoading: false,
                videos: initialReels,
                hasMoreVideos: true, // Ensure hasMoreVideos is set to true to allow pagination
                currentVideoIndex: 0,
                loadingSource: 'network_initial',
              ),
            );
            // Start preloading next videos
            preloadNextVideos();
          }
          // Regardless of initial fetch result, proceed with full background refresh
          _refreshVideosInBackground();
        } catch (e) {
          debugPrint('Error fetching initial reels: $e');
          // Fall back to full network load if initial fetch fails
          loadVideos();
        }
      }
    } catch (e) {
      debugPrint('Error loading cached videos: $e');
      // Fall back to normal loading
      loadVideos();
    }
  }

  /// Refresh videos in background without blocking UI
  Future<void> _refreshVideosInBackground() async {
    if (_isRefreshingInBackground) return;

    _isRefreshingInBackground = true;
    try {
      final freshVideos = await videoRepository.fetchVideos();

      if (freshVideos.isNotEmpty) {
        // Only update if we got new videos and they're different from current ones
        final currentVideos = state.videos;
        final hasNewVideos = freshVideos.any((video) => !currentVideos.any((v) => v.reelID == video.reelID)
        );

        if (hasNewVideos) {
          // Merge with existing videos, keeping current position
          final currentIndex = state.currentVideoIndex;
          final currentVideoId = currentVideos.isNotEmpty && currentIndex < currentVideos.length
              ? currentVideos[currentIndex].reelID
              : null;

          // Find index of current video in new list
          int newIndex = 0;
          if (currentVideoId != null) {
            final matchIndex = freshVideos.indexWhere((v) => v.reelID == currentVideoId);
            if (matchIndex >= 0) {
              newIndex = matchIndex;
            }
          }

          String currentUID = FirebaseAuth.instance.currentUser!.uid;
          freshVideos.removeWhere((video)=> video.reportedByUsers.contains(currentUID));

          emit(
            state.copyWith(
              videos: freshVideos,
              hasMoreVideos: freshVideos.length >= 5,
              currentVideoIndex: newIndex,
              loadingSource: 'background',
            ),
          );

          // Preload videos after background refresh
          preloadNextVideos();
        }
      }
    } catch (e) {
      debugPrint('Background refresh error: $e');
      // Don't emit error state for background refresh
    } finally {
      _isRefreshingInBackground = false;
    }
  }

  Future<void> loadVideos({bool isRefresh = false}) async {
    // Clear preload queue and cached files to prevent memory leaks
    _preloadQueue.clear();
    _preloadedFiles.clear();
    _preloadedFilesLastAccess.clear();
    _preloadDelayTimer?.cancel();

    emit(state.copyWith(
        isLoading: true,
        loadingSource: 'network',
        preloadedVideoUrls: {},
        currentVideoIndex: 0
    ));

    try {
      final videos = await videoRepository.fetchVideos(isRefresh: isRefresh);
      final hasMoreVideos = videos.length >= 3; // Adjusted to ensure pagination is triggered even with fewer initial videos
      String currentUID = FirebaseAuth.instance.currentUser!.uid;
      videos.removeWhere((video)=> video.reportedByUsers.contains(currentUID));
      emit(
        state.copyWith(
          isLoading: false,
          videos: videos,
          hasMoreVideos: hasMoreVideos,
          currentVideoIndex: 0,
          loadingSource: 'network',
        ),
      );
      debugPrint("New reels found: ${videos.length}");

      // Start preloading next videos after initial load
      if (videos.isNotEmpty) {
        preloadNextVideos();
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadMoreVideos() async {
    if (state.isPaginating || !state.hasMoreVideos) return;
    emit(state.copyWith(isPaginating: true));

    debugPrint("Loading more videos");
    try {
      if (state.videos.isNotEmpty) {
        final List<ReelModel> moreVideos = await videoRepository.fetchMoreVideos();
        final bool hasMoreVideos = moreVideos.length >= 5;
        debugPrint("Loading more videos: hasMoreVideos: $hasMoreVideos");
        // Check for duplicates before adding
        final existingIds = state.videos.map((v) => v.reelID).toSet();
        final newVideos = moreVideos.where((v) => !existingIds.contains(v.reelID)).toList();
        debugPrint("Loading more videos: newVideos: ${newVideos.length}");

        if (newVideos.isNotEmpty) {
          String currentUID = FirebaseAuth.instance.currentUser!.uid;
          newVideos.removeWhere((video)=> video.reportedByUsers.contains(currentUID));
          final List<ReelModel> updatedVideos = List<ReelModel>.from(state.videos)
            ..addAll(newVideos);

          debugPrint("Updated reels count: updatedReels: ${updatedVideos.length}");

          emit(
            state.copyWith(
              videos: updatedVideos,
              isPaginating: false,
              hasMoreVideos: hasMoreVideos,
            ),
          );

          // Preload new videos after loading more
          preloadNextVideos();
          debugPrint("PreLoading next reels");
        } else {
          emit(state.copyWith(isPaginating: false, hasMoreVideos: hasMoreVideos));
        }
      }
    } catch (e) {
      emit(state.copyWith(isPaginating: false, error: e.toString()));
    }
  }

  void onPageChanged(int newIndex) async {
    emit(state.copyWith(currentVideoIndex: newIndex));

    // Start preloading next videos
    preloadNextVideos();

    // Smart pagination trigger - load more videos when user is 3 videos away from the end
    if (!_isPreloadingMore &&
        state.hasMoreVideos &&
        newIndex >= state.videos.length - 3) {
      _isPreloadingMore = true;
      await loadMoreVideos();
      _isPreloadingMore = false;
    }
  }

  void removeReportedReel(String reelID) {

    
    // Also remove the reported reel from cache
    final reportedVideo = state.videos.firstWhere((video) => video.reelID == reelID,);
    debugPrint("removeReportedReel received in the videoFeedCubit before: ${state.videos.length}");
    final updatedVideos = state.videos.where((video) => video.reelID != reelID).toList();

    debugPrint("removeReportedReel received in the videoFeedCubit after: ${updatedVideos.length}");
    emit(state.copyWith(videos: updatedVideos));
    if (reportedVideo.reelID.isNotEmpty) {
      ReelsCacheService.removeCachedReel(reportedVideo.videoUrl);
      debugPrint("Removed reported reel from cache: ${reportedVideo.videoUrl}");
    }
  }

  Future<void> preloadNextVideos() async {
    // Cancel any existing preload delay timer
    _preloadDelayTimer?.cancel();

    if (state.videos.isEmpty) return;

    final currentIndex = state.currentVideoIndex;

    // Enhanced preloading strategy for TikTok-like performance

    // 1. Prioritize preloading the next video first for immediate playback
    if (currentIndex + 1 < state.videos.length) {
      final nextVideoUrl = state.videos[currentIndex + 1].videoUrl;
      if (!_preloadedFiles.containsKey(nextVideoUrl) &&
          !_preloadQueue.contains(nextVideoUrl)) {
        _preloadQueue.add(nextVideoUrl);
        // Use high priority for next video - await to ensure it's ready
        await _preloadVideo(nextVideoUrl, highPriority: true, usePriorityCache: true, useCurrentMoodCache: true);
      }
    }

    // 2. Also preload the previous video for smoother backward navigation
    if (currentIndex > 0) {
      final prevVideoUrl = state.videos[currentIndex - 1].videoUrl;
      if (!_preloadedFiles.containsKey(prevVideoUrl) &&
          !_preloadQueue.contains(prevVideoUrl)) {
        _preloadQueue.add(prevVideoUrl);
        // Use medium priority for previous video - don't await to keep UI responsive
        unawaited(_preloadVideo(prevVideoUrl, highPriority: true, usePriorityCache: true));
      }
    }

    // Use a slight delay before preloading additional videos to avoid overloading
    // This ensures the current and next videos are prioritized
    _preloadDelayTimer = Timer(const Duration(milliseconds: 100), () {
      if (state.videos.isEmpty) return;

      // 3. Preload next few videos for faster scrolling experience
      // Increased from 5 to 8 videos for smoother fast scrolling
      final nextVideosToPreload = state.videos
          .skip(currentIndex + 2) // Skip current and next (already handled)
          .take(8) // Preload 8 more for smoother fast scrolling
          .map((v) => (v).videoUrl)
          .where((url) => !_preloadedFiles.containsKey(url) && !_preloadQueue.contains(url));

      for (final videoUrl in nextVideosToPreload) {
        _preloadQueue.add(videoUrl);
        // Don't await these to avoid blocking UI
        unawaited(_preloadVideo(videoUrl, highPriority: false, usePriorityCache: false));
      }

      // 4. Preload a few videos before the previous one for very fast backward scrolling
      if (currentIndex > 1) {
        final prevVideosToPreload = state.videos
            .sublist(0, currentIndex - 1) // Get videos before the previous one
            .reversed // Start from closest to current
            .take(3) // Preload 3 for backward scrolling
            .map((v) => (v).videoUrl)
            .where((url) => !_preloadedFiles.containsKey(url) && !_preloadQueue.contains(url));

        for (final videoUrl in prevVideosToPreload) {
          _preloadQueue.add(videoUrl);
          // Lower priority for backward videos
          unawaited(_preloadVideo(videoUrl, highPriority: false, usePriorityCache: false));
        }
      }

      // 5. Occasionally preload adjacent moods for faster mood switching
      // Only do this when we have a good number of videos preloaded already
      if (_preloadedFiles.length > 10 && math.Random().nextInt(5) == 0) {
        ReelsCacheService.preloadAdjacentMoods();
      }
    });
  }

  Future<void> _preloadVideo(String videoUrl, {
    bool highPriority = false,
    bool usePriorityCache = false,
    bool useCurrentMoodCache = false
  }) async {
    try {
      // Update last access time for this URL
      _preloadedFilesLastAccess[videoUrl] = DateTime.now().millisecondsSinceEpoch;

      // For high priority videos, await the result to ensure it's ready
      if (highPriority) {
        final file = await getCachedVideoFile(
            videoUrl,
            usePriorityCache: usePriorityCache,
            useCurrentMoodCache: useCurrentMoodCache
        );

        _preloadedFiles[videoUrl] = file;

        final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)
          ..add(videoUrl);
        emit(state.copyWith(preloadedVideoUrls: currentPreloaded));
      } else {
        // For lower priority videos, don't block the UI thread
        getCachedVideoFile(
            videoUrl,
            usePriorityCache: usePriorityCache,
            useCurrentMoodCache: useCurrentMoodCache
        ).then((file) {
          _preloadedFiles[videoUrl] = file;

          final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)
            ..add(videoUrl);
          emit(state.copyWith(preloadedVideoUrls: currentPreloaded));
        }).catchError((e) {
          debugPrint('Error preloading video: $e');
        });
      }

      // Enforce memory cache size limit
      _enforceMemoryCacheLimit();
    } catch (e) {
      debugPrint('Error preloading video: $e');
    } finally {
      _preloadQueue.remove(videoUrl);
    }
  }

  /// Enforce memory cache size limit using LRU strategy
  void _enforceMemoryCacheLimit() {
    if (_preloadedFiles.length <= _maxMemoryCacheSize) return;

    // Sort URLs by last access time (oldest first)
    final sortedUrls = _preloadedFilesLastAccess.entries
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Remove oldest entries until we're under the limit
    final urlsToRemove = sortedUrls
        .take(sortedUrls.length - _maxMemoryCacheSize)
        .map((e) => e.key)
        .toList();

    for (final url in urlsToRemove) {
      _preloadedFiles.remove(url);
      _preloadedFilesLastAccess.remove(url);
    }
  }

  void setShouldPauseVideo(bool value) {
    debugPrint("ShouldPauseState received: $value");

    // Only emit if the state is actually changing to avoid unnecessary rebuilds
    if (state.shouldPauseVideo != value) {
      emit(state.copyWith(shouldPauseVideo: value));
    }
  }

  Future<File> getCachedVideoFile(String videoUrl, {
    bool usePriorityCache = false,
    bool useCurrentMoodCache = false
  }) async {
    // Update last access time for this URL
    _preloadedFilesLastAccess[videoUrl] = DateTime.now().millisecondsSinceEpoch;

    // Return from memory cache if available for fastest access
    if (_preloadedFiles.containsKey(videoUrl)) {
      final file = _preloadedFiles[videoUrl]!;
      // Verify the file still exists
      if (await file.exists()) {
        return file;
      } else {
        // Remove invalid file from memory cache
        _preloadedFiles.remove(videoUrl);
        _preloadedFilesLastAccess.remove(videoUrl);
      }
    }

    try {
      // First try to get from our persistent cache for fast loading
      final cachedFile = await ReelsCacheService.getCachedVideo(videoUrl);
      if (cachedFile != null) {
        // Verify the file exists and is readable before returning
        if (await cachedFile.exists()) {
          // Check file size to ensure it's a valid video file
          final fileSize = await cachedFile.length();
          if (fileSize > 0) {
            _preloadedFiles[videoUrl] = cachedFile;

            // Add to preloaded URLs set to indicate it's ready for immediate playback
            final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)
              ..add(videoUrl);
            emit(state.copyWith(preloadedVideoUrls: currentPreloaded));

            return cachedFile;
          }
        }
        // If file doesn't exist or is empty, continue to download it again
      }

      // If not in our cache, use the enhanced cache service with priority support
      // This will download and cache the file if needed
      final file = await ReelsCacheService.preCacheVideo(
          videoUrl,
          highPriority: true,
          usePriorityCache: usePriorityCache,
          useCurrentMoodCache: useCurrentMoodCache
      );

      // Verify the downloaded file
      if (await file.exists() && await file.length() > 0) {
        // Store in memory cache for faster access next time
        _preloadedFiles[videoUrl] = file;

        // Add to preloaded URLs set
        final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)
          ..add(videoUrl);
        emit(state.copyWith(preloadedVideoUrls: currentPreloaded));

        // Enforce memory cache size limit
        _enforceMemoryCacheLimit();

        return file;
      } else {
        throw Exception('Downloaded file is invalid or empty');
      }
    } catch (e) {
      // Fall back to default cache manager if our cache fails
      debugPrint('Error using custom cache, falling back to default: $e');
      try {
        final cacheManager = DefaultCacheManager();
        final fileInfo = await cacheManager.getFileFromCache(videoUrl);

        if (fileInfo != null) {
          final file = fileInfo.file;
          _preloadedFiles[videoUrl] = file;

          // Add to preloaded URLs set
          final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)
            ..add(videoUrl);
          emit(state.copyWith(preloadedVideoUrls: currentPreloaded));

          return file;
        }

        // If not in cache, download it with retry logic
        File? file;
        int retries = 3;

        while (retries > 0 && (file == null || !(await file.exists()))) {
          try {
            file = await cacheManager.getSingleFile(videoUrl);
            break;
          } catch (retryError) {
            retries--;
            if (retries > 0) {
              // Wait before retry with exponential backoff
              await Future.delayed(Duration(milliseconds: 200 * math.pow(2, 3 - retries).toInt()));
            }
          }
        }

        if (file != null && await file.exists()) {
          _preloadedFiles[videoUrl] = file;

          // Add to preloaded URLs set
          final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)
            ..add(videoUrl);
          emit(state.copyWith(preloadedVideoUrls: currentPreloaded));

          return file;
        }

        // If all retries fail, create a fallback file
        final tempDir = await getTemporaryDirectory();
        final fallbackFile = File('${tempDir.path}/fallback_${DateTime.now().millisecondsSinceEpoch}.mp4');
        await fallbackFile.create();
        return fallbackFile;
      } catch (innerError) {
        // If all caching methods fail, create a fallback file to prevent crashes
        debugPrint('Failed to cache video after multiple attempts: $innerError');
        final tempDir = await getTemporaryDirectory();
        final fallbackFile = File('${tempDir.path}/fallback_${DateTime.now().millisecondsSinceEpoch}.mp4');
        try {
          await fallbackFile.create();
        } catch (e) {
          // Ignore errors when creating fallback file
        }
        return fallbackFile;
      }
    }
  }

  @override
  Future<void> close() {
    _backgroundRefreshTimer?.cancel();
    _preloadDelayTimer?.cancel();
    _preloadQueue.clear();
    _preloadedFiles.clear();
    _preloadedFilesLastAccess.clear();

    // Clean up memory cache in ReelsCacheService to prevent memory leaks
    ReelsCacheService.cleanupMemoryCache();

    return super.close();
  }

  Future<void> onMoodChange({required String mood}) async {
    // Clear preload queue and cached files to prevent memory leaks
    _preloadQueue.clear();
    _preloadedFiles.clear();
    _preloadedFilesLastAccess.clear();
    _preloadDelayTimer?.cancel();

    // Create a timeout timer to ensure loading state is reset
    Timer? loadingTimeoutTimer;
    loadingTimeoutTimer = Timer(const Duration(seconds: 2), () {
      if (state.isLoading) {
        emit(state.copyWith(
          isLoading: false,
        ));
      }
    });

    // Reset preloaded video URLs to prevent audio from previous mood's videos
    emit(state.copyWith(
      preloadedVideoUrls: {},
      currentVideoIndex: 0,
      isLoading: true,
      loadingSource: 'cache',
    ));

    // Update user preferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(LocalStorageConstants.currentMoodKey, mood);
    await UserService.updateMoodTo(mood);

    // First try to load from cache for immediate response
    try {
      final cachedReels = await ReelsCacheService.getCachedReels(mood);
      if (cachedReels.isNotEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            videos: cachedReels,
            hasMoreVideos: true,
            currentVideoIndex: 0,
            loadingSource: 'cache',
          ),
        );

        // Cancel the timeout timer since we've successfully loaded from cache
        loadingTimeoutTimer.cancel();

        // Immediately start preloading the first few videos with high priority
        if (cachedReels.isNotEmpty) {
          try {
            // Preload first video with highest priority and await to ensure it's ready
            final firstVideoUrl = cachedReels[0].videoUrl;
            await _preloadVideo(
                firstVideoUrl,
                highPriority: true,
                usePriorityCache: true,
                useCurrentMoodCache: true
            );

            // Preload next few videos with high priority but don't await
            // This ensures smooth scrolling right after mood change
            for (int i = 1; i < math.min(5, cachedReels.length); i++) {
              unawaited(_preloadVideo(
                  cachedReels[i].videoUrl,
                  highPriority: i < 3, // First 3 are high priority
                  usePriorityCache: true, // All use priority cache
                  useCurrentMoodCache: i < 3 // First 3 use current mood cache
              ));
            }

            // Then preload more videos in background with a slight delay
            // to avoid overloading the system
            _preloadDelayTimer = Timer(const Duration(milliseconds: 300), () {
              preloadNextVideos();

              // Also start preloading adjacent moods for faster future mood changes
              ReelsCacheService.preloadAdjacentMoods();
            });
          } catch (e) {
            debugPrint('Error preloading initial videos for mood change: $e');
          }
        }
      } else {
        // If no cached reels, show loading indicator
        emit(
          state.copyWith(
            isLoading: true,
            videos: [],
            loadingSource: 'network',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading cached reels: $e');
      // If loading from cache fails, ensure we're not stuck in loading state
      emit(
        state.copyWith(
          isLoading: true,
          videos: [],
          loadingSource: 'network',
        ),
      );
    }

    // Then load from network (even if we have cached reels, to get fresh content)
    try {
      await loadVideos();
      // Cancel the timeout timer since we've successfully loaded from network
      loadingTimeoutTimer.cancel();
    } catch (e) {
      debugPrint('Error loading videos from network: $e');
      // If loading from network fails, ensure we're not stuck in loading state
      if (state.isLoading) {
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      }
    }
  }

  // Call this from your widget's initState or after BlocProvider is created
  Future<void> initialize() async {
    await _initializeVideos();
  }
}
