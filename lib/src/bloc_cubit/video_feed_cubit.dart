import 'dart:io';
import 'dart:collection';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:funli_app/src/bloc_cubit/video_feed_state.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/local_storage_constants.dart';
import 'package:funli_app/src/services/reels_cache_service.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repository/i_video_feed_repository.dart';

class VideoFeedCubit extends Cubit<VideoFeedState> {
  VideoFeedCubit(this.videoRepository) : super(VideoFeedState.initial()) {
    // Load videos immediately on initialization
    _initializeVideos();
  }

  final IVideoFeedRepository videoRepository;
  final _preloadQueue = Queue<String>();
  final _preloadedFiles = <String, File>{};
  bool _isPreloadingMore = false;
  bool _isRefreshingInBackground = false;
  Timer? _backgroundRefreshTimer;
  
  /// Initialize videos with optimized loading strategy
  Future<void> _initializeVideos() async {
    // First load cached videos immediately
    await _loadCachedVideosFirst();
    
    // Then start background refresh timer
    _startBackgroundRefreshTimer();
  }
  
  /// Start a timer to periodically refresh videos in the background
  void _startBackgroundRefreshTimer() {
    _backgroundRefreshTimer?.cancel();
    _backgroundRefreshTimer = Timer.periodic(
      const Duration(minutes: 15),
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
        // Emit cached reels immediately
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
        // If no cached reels, load from network
        loadVideos();
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
        final hasNewVideos = freshVideos.any(
          (video) => !currentVideos.any((v) => v.reelID == video.reelID)
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

  Future<void> loadVideos() async {
    emit(state.copyWith(isLoading: true, loadingSource: 'network'));
    try {
      final videos = await videoRepository.fetchVideos();
      final hasMoreVideos = videos.length >= 5;
      emit(
        state.copyWith(
          isLoading: false,
          videos: videos,
          hasMoreVideos: hasMoreVideos,
          currentVideoIndex: 0,
          loadingSource: 'network',
        ),
      );

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

    try {
      if (state.videos.isNotEmpty) {
        final List<ReelModel> moreVideos =
            await videoRepository.fetchMoreVideos();
        final bool hasMoreVideos = moreVideos.length >= 5;
        
        // Check for duplicates before adding
        final existingIds = state.videos.map((v) => v.reelID).toSet();
        final newVideos = moreVideos.where((v) => !existingIds.contains(v.reelID)).toList();
        
        if (newVideos.isNotEmpty) {
          final List<ReelModel> updatedVideos = List<ReelModel>.from(state.videos)
            ..addAll(newVideos);

          emit(
            state.copyWith(
              videos: updatedVideos,
              isPaginating: false,
              hasMoreVideos: hasMoreVideos,
            ),
          );

          // Preload new videos after loading more
          preloadNextVideos();
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

  Future<void> preloadNextVideos() async {
    if (state.videos.isEmpty) return;

    final currentIndex = state.currentVideoIndex;
    
    // Prioritize preloading the next video first for immediate playback
    if (currentIndex + 1 < state.videos.length) {
      final nextVideoUrl = state.videos[currentIndex + 1].videoUrl;
      if (!_preloadedFiles.containsKey(nextVideoUrl) && 
          !_preloadQueue.contains(nextVideoUrl)) {
        _preloadQueue.add(nextVideoUrl);
        // Use high priority for next video
        await _preloadVideo(nextVideoUrl, highPriority: true);
      }
    }
    
    // Then preload additional videos for smoother experience
    final videosToPreload = state.videos
        .skip(currentIndex + 2) // Skip current and next (already handled)
        .take(2) // Only preload 2 more to reduce memory usage
        .map((v) => (v).videoUrl)
        .where((url) => !_preloadedFiles.containsKey(url));

    for (final videoUrl in videosToPreload) {
      if (!_preloadQueue.contains(videoUrl)) {
        _preloadQueue.add(videoUrl);
        // Don't await these to avoid blocking UI
        _preloadVideo(videoUrl, highPriority: false);
      }
    }
    
    // Don't preload previous videos to prevent them from playing when not visible
  }

  Future<void> _preloadVideo(String videoUrl, {bool highPriority = false}) async {
    try {
      // For high priority videos, await the result to ensure it's ready
      if (highPriority) {
        final file = await getCachedVideoFile(videoUrl);
        _preloadedFiles[videoUrl] = file;
  
        final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)
          ..add(videoUrl);
        emit(state.copyWith(preloadedVideoUrls: currentPreloaded));
      } else {
        // For lower priority videos, don't block the UI thread
        getCachedVideoFile(videoUrl).then((file) {
          _preloadedFiles[videoUrl] = file;
          
          final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)
            ..add(videoUrl);
          emit(state.copyWith(preloadedVideoUrls: currentPreloaded));
        }).catchError((e) {
          debugPrint('Error preloading video: $e');
        });
      }
    } catch (e) {
      debugPrint('Error preloading video: $e');
    } finally {
      _preloadQueue.remove(videoUrl);
    }
  }

  void setShouldPauseVideo(bool value) {
    debugPrint("ShouldPauseState received: $value");
    emit(state.copyWith(shouldPauseVideo: value));
  }

  Future<File> getCachedVideoFile(String videoUrl) async {
    // Return from memory cache if available for fastest access
    if (_preloadedFiles.containsKey(videoUrl)) {
      return _preloadedFiles[videoUrl]!;
    }

    try {
      // First try to get from our persistent cache for fast loading
      final cachedFile = await ReelsCacheService.getCachedVideo(videoUrl);
      if (cachedFile != null) {
        _preloadedFiles[videoUrl] = cachedFile;
        return cachedFile;
      }
      
      // If not in our cache, use the custom cache manager with longer retention
      // This will download and cache the file if needed
      final file = await ReelsCacheService.preCacheVideo(videoUrl);
      
      // Store in memory cache for faster access next time
      _preloadedFiles[videoUrl] = file;
      
      // Limit memory cache size to prevent OOM issues
      if (_preloadedFiles.length > 10) {
        // Remove oldest entries when cache gets too large
        final keysToRemove = _preloadedFiles.keys.take(_preloadedFiles.length - 10).toList();
        for (final key in keysToRemove) {
          _preloadedFiles.remove(key);
        }
      }
      
      return file;
    } catch (e) {
      // Fall back to default cache manager if our cache fails
      debugPrint('Error using custom cache, falling back to default: $e');
      try {
        final cacheManager = DefaultCacheManager();
        final fileInfo = await cacheManager.getFileFromCache(videoUrl);
        final file = fileInfo?.file ?? await cacheManager.getSingleFile(videoUrl);
        _preloadedFiles[videoUrl] = file;
        return file;
      } catch (innerError) {
        // If all caching methods fail, rethrow with more context
        throw Exception('Failed to cache video after multiple attempts: $innerError');
      }
    }
  }

  @override
  Future<void> close() {
    _backgroundRefreshTimer?.cancel();
    _preloadQueue.clear();
    _preloadedFiles.clear();
    return super.close();
  }

  Future<void> onMoodChange({required String mood}) async {
    _preloadQueue.clear();
    _preloadedFiles.clear();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(LocalStorageConstants.currentMoodKey, mood);

    await UserService.updateMoodTo(mood);
    
    // First try to load from cache for immediate response
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
      
      // Start preloading
      preloadNextVideos();
    }
    
    // Then load from network
    loadVideos();
  }
}
