import 'dart:io';
import 'dart:collection';
import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:funli_app/src/features/main_menu/updated_feed_view/bloc_cubit/updated_feed_state.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/local_storage_constants.dart';
import 'package:funli_app/src/services/reels_cache_service.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repo/i_video_feed_repository.dart';


class UpdatedFeedCubit extends Cubit<UpdatedFeedState> {
  UpdatedFeedCubit(this.videoRepository) : super(UpdatedFeedState.initial());

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
  final int _maxMemoryCacheSize = 15;

  /// Initialize videos with optimized loading strategy
  Future<void> _initializeVideos() async {
    await _loadCachedVideosFirst();
    _startBackgroundRefreshTimer();
    ReelsCacheService.preloadAllMoods();
  }

  /// Start a timer to periodically refresh videos in the background
  void _startBackgroundRefreshTimer() {
    _backgroundRefreshTimer?.cancel();
    _backgroundRefreshTimer = Timer.periodic(
      const Duration(minutes: 2), // Further reduced for fresher content
          (_) => _refreshVideosInBackground(),
    );
  }

  /// Load cached videos first for immediate display
  Future<void> _loadCachedVideosFirst() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mood = prefs.getString(LocalStorageConstants.currentMoodKey) ?? 'Happy';
      final cachedReels = await ReelsCacheService.getCachedReels(mood);

      if (cachedReels.isNotEmpty) {
        String currentUID = FirebaseAuth.instance.currentUser!.uid;
        cachedReels.removeWhere((video) => video.reportedByUsers.contains(currentUID));

        emit(
          state.copyWith(
            isLoading: false,
            videos: cachedReels,
            hasMoreVideos: true,
            currentVideoIndex: 0,
            loadingSource: 'cache',
          ),
        );

        preloadNextVideos();
        _refreshVideosInBackground();
      } else {
        emit(
          state.copyWith(
            isLoading: true,
            loadingSource: 'network_initial',
          ),
        );
        try {
          final initialReels = await videoRepository.fetchVideos(limit: cachedReels.isEmpty ? 5 : 3);
          if (initialReels.isNotEmpty) {
            emit(
              state.copyWith(
                isLoading: false,
                videos: initialReels,
                hasMoreVideos: true,
                currentVideoIndex: 0,
                loadingSource: 'network_initial',
              ),
            );
            preloadNextVideos();
          }
          _refreshVideosInBackground();
        } catch (e) {
          debugPrint('Error fetching initial reels: $e');
          loadVideos();
        }
      }
    } catch (e) {
      debugPrint('Error loading cached videos: $e');
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
        final currentVideos = state.videos;
        final hasNewVideos = freshVideos.any((video) => !currentVideos.any((v) => v.reelID == video.reelID));

        if (hasNewVideos) {
          final currentIndex = state.currentVideoIndex;
          final currentVideoId = currentVideos.isNotEmpty && currentIndex < currentVideos.length
              ? currentVideos[currentIndex].reelID
              : null;

          int newIndex = 0;
          if (currentVideoId != null) {
            final matchIndex = freshVideos.indexWhere((v) => v.reelID == currentVideoId);
            if (matchIndex >= 0) {
              newIndex = matchIndex;
            }
          }

          String currentUID = FirebaseAuth.instance.currentUser!.uid;
          freshVideos.removeWhere((video) => video.reportedByUsers.contains(currentUID));

          emit(
            state.copyWith(
              videos: freshVideos,
              hasMoreVideos: freshVideos.length >= 5,
              currentVideoIndex: newIndex,
              loadingSource: 'background',
            ),
          );

          preloadNextVideos();
        }
      }
    } catch (e) {
      debugPrint('Background refresh error: $e');
    } finally {
      _isRefreshingInBackground = false;
    }
  }

  Future<void> loadVideos({bool isRefresh = false}) async {
    _preloadQueue.clear();
    _preloadedFiles.clear();
    _preloadedFilesLastAccess.clear();
    _preloadDelayTimer?.cancel();

    emit(state.copyWith(
      isLoading: true,
      loadingSource: 'network',
      preloadedVideoUrls: {},
      currentVideoIndex: 0,
    ));

    try {
      final videos = await videoRepository.fetchVideos(isRefresh: isRefresh);
      final hasMoreVideos = videos.length >= 3;
      String currentUID = FirebaseAuth.instance.currentUser!.uid;
      videos.removeWhere((video) => video.reportedByUsers.contains(currentUID));
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
        final existingIds = state.videos.map((v) => v.reelID).toSet();
        final newVideos = moreVideos.where((v) => !existingIds.contains(v.reelID)).toList();
        debugPrint("Loading more videos: newVideos: ${newVideos.length}");

        if (newVideos.isNotEmpty) {
          String currentUID = FirebaseAuth.instance.currentUser!.uid;
          newVideos.removeWhere((video) => video.reportedByUsers.contains(currentUID));
          final List<ReelModel> updatedVideos = List<ReelModel>.from(state.videos)..addAll(newVideos);

          debugPrint("Updated reels count: updatedReels: ${updatedVideos.length}");

          emit(
            state.copyWith(
              videos: updatedVideos,
              isPaginating: false,
              hasMoreVideos: hasMoreVideos,
            ),
          );

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
    preloadNextVideos();

    if (!_isPreloadingMore && state.hasMoreVideos && newIndex >= state.videos.length - 7) {
      _isPreloadingMore = true;
      await loadMoreVideos();
      _isPreloadingMore = false;
    }
  }

  void removeReportedReel(String reelID) {
    final reportedVideo = state.videos.firstWhere((video) => video.reelID == reelID);
    debugPrint("removeReportedReel received in the updatedFeedCubit before: ${state.videos.length}");
    final updatedVideos = state.videos.where((video) => video.reelID != reelID).toList();

    debugPrint("removeReportedReel received in the updatedFeedCubit after: ${updatedVideos.length}");
    emit(state.copyWith(videos: updatedVideos));
    if (reportedVideo.reelID.isNotEmpty) {
      ReelsCacheService.removeCachedReel(reportedVideo.videoUrl);
      debugPrint("Removed reported reel from cache: ${reportedVideo.videoUrl}");
    }
  }

  Future<void> preloadNextVideos() async {
    _preloadDelayTimer?.cancel();
    if (state.videos.isEmpty) return;

    final currentIndex = state.currentVideoIndex;

    if (currentIndex + 1 < state.videos.length) {
      final nextVideoUrl = state.videos[currentIndex + 1].videoUrl;
      if (!_preloadedFiles.containsKey(nextVideoUrl) && !_preloadQueue.contains(nextVideoUrl)) {
        _preloadQueue.add(nextVideoUrl);
        await _preloadVideo(nextVideoUrl, highPriority: true, usePriorityCache: true, useCurrentMoodCache: true);
      }
    }

    if (currentIndex > 0) {
      final prevVideoUrl = state.videos[currentIndex - 1].videoUrl;
      if (!_preloadedFiles.containsKey(prevVideoUrl) && !_preloadQueue.contains(prevVideoUrl)) {
        _preloadQueue.add(prevVideoUrl);
        await _preloadVideo(prevVideoUrl, highPriority: true, usePriorityCache: true, useCurrentMoodCache: true);
      }
    }

    _preloadDelayTimer = Timer(const Duration(milliseconds: 30), () {
      if (state.videos.isEmpty) return;

      final nextVideosToPreload = state.videos
          .skip(currentIndex + 2)
          .take(3)
          .map((v) => (v).videoUrl)
          .where((url) => !_preloadedFiles.containsKey(url) && !_preloadQueue.contains(url));

      for (final videoUrl in nextVideosToPreload) {
        _preloadQueue.add(videoUrl);
        unawaited(_preloadVideo(videoUrl, highPriority: false, usePriorityCache: false));
      }

      if (currentIndex > 1) {
        final prevVideosToPreload = state.videos
            .sublist(0, currentIndex - 1)
            .reversed
            .take(1)
            .map((v) => (v).videoUrl)
            .where((url) => !_preloadedFiles.containsKey(url) && !_preloadQueue.contains(url));

        for (final videoUrl in prevVideosToPreload) {
          _preloadQueue.add(videoUrl);
          unawaited(_preloadVideo(videoUrl, highPriority: true, usePriorityCache: false));
        }
      }

      if (_preloadedFiles.length > 6 && math.Random().nextInt(5) == 0) {
        ReelsCacheService.preloadAdjacentMoods();
      }
    });
  }

  Future<void> _preloadVideo(String videoUrl,
      {bool highPriority = false, bool usePriorityCache = false, bool useCurrentMoodCache = false}) async {
    try {
      _preloadedFilesLastAccess[videoUrl] = DateTime.now().millisecondsSinceEpoch;

      if (highPriority) {
        final file = await getCachedVideoFile(videoUrl,
            usePriorityCache: usePriorityCache, useCurrentMoodCache: useCurrentMoodCache);
        _preloadedFiles[videoUrl] = file;

        final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)..add(videoUrl);
        emit(state.copyWith(preloadedVideoUrls: currentPreloaded));
      } else {
        getCachedVideoFile(videoUrl,
            usePriorityCache: usePriorityCache, useCurrentMoodCache: useCurrentMoodCache)
            .then((file) {
          _preloadedFiles[videoUrl] = file;

          final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)..add(videoUrl);
          emit(state.copyWith(preloadedVideoUrls: currentPreloaded));
        }).catchError((e) {
          debugPrint('Error preloading video: $e');
        });
      }

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

    final sortedUrls = _preloadedFilesLastAccess.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

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
    if (state.shouldPauseVideo != value) {
      emit(state.copyWith(shouldPauseVideo: value));
    }
  }

  Future<File> getCachedVideoFile(String videoUrl,
      {bool usePriorityCache = false, bool useCurrentMoodCache = false}) async {
    _preloadedFilesLastAccess[videoUrl] = DateTime.now().millisecondsSinceEpoch;

    if (_preloadedFiles.containsKey(videoUrl)) {
      final file = _preloadedFiles[videoUrl]!;
      if (await file.exists()) {
        return file;
      } else {
        _preloadedFiles.remove(videoUrl);
        _preloadedFilesLastAccess.remove(videoUrl);
      }
    }

    try {
      final cachedFile = await ReelsCacheService.getCachedVideo(videoUrl);
      if (cachedFile != null) {
        if (await cachedFile.exists()) {
          final fileSize = await cachedFile.length();
          if (fileSize > 0) {
            _preloadedFiles[videoUrl] = cachedFile;
            final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)..add(videoUrl);
            emit(state.copyWith(preloadedVideoUrls: currentPreloaded));
            return cachedFile;
          }
        }
      }

      final file = await ReelsCacheService.preCacheVideo(videoUrl,
          highPriority: true,
          usePriorityCache: usePriorityCache,
          useCurrentMoodCache: useCurrentMoodCache);

      if (await file.exists() && await file.length() > 0) {
        _preloadedFiles[videoUrl] = file;
        final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)..add(videoUrl);
        emit(state.copyWith(preloadedVideoUrls: currentPreloaded));
        _enforceMemoryCacheLimit();
        return file;
      } else {
        throw Exception('Downloaded file is invalid or empty');
      }
    } catch (e) {
      debugPrint('Error using custom cache, falling back to default: $e');
      try {
        final cacheManager = DefaultCacheManager();
        final fileInfo = await cacheManager.getFileFromCache(videoUrl);

        if (fileInfo != null) {
          final file = fileInfo.file;
          _preloadedFiles[videoUrl] = file;
          final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)..add(videoUrl);
          emit(state.copyWith(preloadedVideoUrls: currentPreloaded));
          return file;
        }

        File? file;
        int retries = 3;

        while (retries > 0 && (file == null || !(await file.exists()))) {
          try {
            file = await cacheManager.getSingleFile(videoUrl);
            break;
          } catch (retryError) {
            retries--;
            if (retries > 0) {
              await Future.delayed(Duration(milliseconds: 200 * math.pow(2, 3 - retries).toInt()));
            }
          }
        }

        if (file != null && await file.exists()) {
          _preloadedFiles[videoUrl] = file;
          final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)..add(videoUrl);
          emit(state.copyWith(preloadedVideoUrls: currentPreloaded));
          return file;
        }

        final tempDir = await getTemporaryDirectory();
        final fallbackFile = File('${tempDir.path}/fallback_${DateTime.now().millisecondsSinceEpoch}.mp4');
        await fallbackFile.create();
        return fallbackFile;
      } catch (innerError) {
        debugPrint('Failed to cache video after multiple attempts: $innerError');
        final tempDir = await getTemporaryDirectory();
        final fallbackFile = File('${tempDir.path}/fallback_${DateTime.now().millisecondsSinceEpoch}.mp4');
        try {
          await fallbackFile.create();
        } catch (e) {}
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
    ReelsCacheService.cleanupMemoryCache();
    return super.close();
  }

  Future<void> onMoodChange({required String mood}) async {
    _preloadDelayTimer?.cancel();

    Timer? loadingTimeoutTimer;
    loadingTimeoutTimer = Timer(const Duration(milliseconds: 500), () {
      if (state.isLoading) {
        emit(state.copyWith(isLoading: false));
      }
    });

    emit(state.copyWith(
      currentVideoIndex: 0,
      isLoading: true,
      loadingSource: 'cache',
    ));

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(LocalStorageConstants.currentMoodKey, mood);
    await UserService.updateMoodTo(mood);

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

        loadingTimeoutTimer.cancel();

        if (cachedReels.isNotEmpty) {
          try {
            final firstVideoUrl = cachedReels[0].videoUrl;
            await _preloadVideo(firstVideoUrl,
                highPriority: true, usePriorityCache: true, useCurrentMoodCache: true);

            for (int i = 1; i < math.min(2, cachedReels.length); i++) {
              unawaited(_preloadVideo(cachedReels[i].videoUrl,
                  highPriority: true, usePriorityCache: true, useCurrentMoodCache: true));
            }

            _preloadDelayTimer = Timer(const Duration(milliseconds: 100), () {
              preloadNextVideos();
              ReelsCacheService.preloadAdjacentMoods();
            });
          } catch (e) {
            debugPrint('Error preloading initial videos for mood change: $e');
          }
        }
      } else {
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
      emit(
        state.copyWith(
          isLoading: true,
          videos: [],
          loadingSource: 'network',
        ),
      );
    }

    try {
      await loadVideos();
      loadingTimeoutTimer.cancel();
    } catch (e) {
      debugPrint('Error loading videos from network: $e');
      if (state.isLoading) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    }
  }

  Future<void> initialize() async {
    await _initializeVideos();
  }
}