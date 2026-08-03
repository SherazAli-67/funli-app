import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/features/reels_page/bloc_cubit/reels_cubit.dart';
import 'package:funli_app/src/features/reels_page/reel_repository.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/enhanced_video_feed_service.dart';
import 'package:funli_app/src/services/reels_cache_service.dart';
import 'package:funli_app/src/services/reels_service.dart';
import 'package:funli_app/src/widgets/enhanced_video_feed_item.dart';
import 'package:preload_page_view/preload_page_view.dart';

import '../../../services/publish_reel_service.dart';

import '../../../services/publish_reel_service.dart';

class VideoFeedView extends StatefulWidget {
  final String? initialMood;
  final List<ReelModel>? initialReels;

  const VideoFeedView({
    super.key,
    this.initialMood,
    this.initialReels,
  });

  @override
  State<VideoFeedView> createState() => VideoFeedViewState();
}

// Global key to access VideoFeedView from outside
final GlobalKey<VideoFeedViewState> videoFeedViewKey = GlobalKey<VideoFeedViewState>();

class VideoFeedViewState extends State<VideoFeedView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  
  // Controllers and services
  late PreloadPageController _pageController;
  late EnhancedVideoFeedService _videoService;
  late ReelsCubit _reelsCubit;
  
  // State management
  List<ReelModel> _reels = [];
  int _currentIndex = 0;
  String _currentMood = 'Happy';
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isRefreshing = false;
  
  // Firebase pagination
  DocumentSnapshot? _lastDocument;
  bool _hasMoreReels = true;
  bool _isLoadingMore = false;
  
  // Performance tracking
  final Completer<void> _initCompleter = Completer<void>();
  Timer? _preloadTimer;
  Timer? _backgroundRefreshTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _pageController = PreloadPageController(initialPage: 0);
    _videoService = EnhancedVideoFeedService();

    _initializeVideoFeed();
  }

  /// Public method to refresh the video feed
  Future<void> refreshVideoFeed() async {
    if (_isRefreshing || _isLoading) return;

    setState(() => _isRefreshing = true);

    try {
      // Pause all videos and clear controllers
      await _videoService.pauseAll();
      
      // Animate to first position smoothly
      if (_pageController.hasClients && _currentIndex != 0) {
        await _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }

      // Clear cache and fetch fresh reels
      await ReelsCacheService.clearCachedReels(_currentMood);
      
      // Fetch fresh reels from Firebase (for now using AppData as fallback)
      final freshReels = await _fetchFreshReelsFromFirebase();
      
      setState(() {
        _reels = freshReels;
        _currentIndex = 0;
        _isRefreshing = false;
      });

      // Cache the fresh reels
      await ReelsCacheService.cacheReels(_reels, _currentMood);

      // Restart smart preloading for fresh content
      await _startSmartPreloading();

      debugPrint('Video feed refreshed with ${freshReels.length} fresh reels');

    } catch (e) {
      debugPrint('Failed to refresh video feed: $e');
      
      // Fallback to existing reels if refresh fails
      if (_reels.isEmpty) {
        _reels = AppData.getReels().take(10).toList();
      }
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  /// Fetch fresh reels from Firebase
  Future<List<ReelModel>> _fetchFreshReelsFromFirebase() async {
    try {
      debugPrint('Fetching fresh reels from Firebase for mood: $_currentMood');
      
      // Reset pagination for fresh fetch
      _lastDocument = null;
      _hasMoreReels = true;
      
      final freshReels = await ReelsService.fetchReelsByMood(
        mood: _currentMood,
        lastDoc: null, // Start fresh
        limit: 5, // Load first batch
        onLastDoc: (doc) => _lastDocument = doc,
        onHasMore: (hasMore) => _hasMoreReels = hasMore,
      );
      
      debugPrint('Fetched ${freshReels.length} fresh reels from Firebase');
      return freshReels;
      
    } catch (e) {
      debugPrint('Failed to fetch from Firebase: $e');
      
      // Try to get from main reels collection as fallback
      try {
        debugPrint('Attempting fallback fetch from main reels collection');
        final fallbackReels = await ReelsService.fetchMoreReels(
          lastDoc: null,
          limit: 10,
          onLastDoc: (doc) => _lastDocument = doc,
          onHasMore: (hasMore) => _hasMoreReels = hasMore,
        );
        debugPrint('Fallback fetch successful: ${fallbackReels.length} reels');
        return fallbackReels;
      } catch (fallbackError) {
        debugPrint('Fallback fetch also failed: $fallbackError');
        // Only use dummy data in debug mode, return empty in production
        if (kDebugMode) {
          debugPrint('Debug mode: returning dummy data as last resort');
          return AppData.getReels().take(5).toList();
        }
        return []; // Return empty list in production
      }
    }
  }

  Future<void> uploadFeels() async {
    AppData.getReels().forEach((reel) async {

      bool isUploaded = await PublishReelService.uploadReel(reel: reel);
      debugPrint("isUploaded: $isUploaded");
    });
  }

  Future<void> _initializeVideoFeed() async {
    setState(()=>  _isLoading = true);

    try {
      await _videoService.initialize();
      
      _currentMood = widget.initialMood ?? await ReelsCacheService.getCurrentMood();
      
      if (widget.initialReels != null && widget.initialReels!.isNotEmpty) {
        _reels = widget.initialReels!;
      } else {
        _reels = await ReelsCacheService.getCachedReels(_currentMood);
        debugPrint("Cached reels: ${_reels.length}");
        if (_reels.isEmpty) {
          debugPrint('No cached reels found, fetching from Firebase');
          _reels = await _fetchFreshReelsFromFirebase();
          
          if (_reels.isNotEmpty) {
            await ReelsCacheService.cacheReels(_reels, _currentMood);
          }
        }
      }
      
      _reelsCubit = ReelsCubit(
        ReelsRepository(
          initialReels: _reels,
          mood: _currentMood,
          comingFrom: 'video_feed', lastDoc: null,
        ),
      );
      
      await _startSmartPreloading();
      
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
      
      _initCompleter.complete();
      
      _startBackgroundOptimizations();
      
    } catch (e) {
      debugPrint('Failed to initialize video feed: $e');
      setState(() {
        _isLoading = false;
      });
      
      try {
        debugPrint('Initialization failed, attempting emergency Firebase fetch');
        _reels = await _fetchFreshReelsFromFirebase();
        
        if (_reels.isNotEmpty) {
          await ReelsCacheService.cacheReels(_reels, _currentMood);
        }
      } catch (emergencyError) {
        debugPrint('Emergency fetch failed: $emergencyError');
        // Only use dummy data in debug mode
        if (kDebugMode) {
          _reels = AppData.getReels().take(5).toList();
        }
        // In production, _reels remains empty and will show empty state
      }
      
      setState(() {
        _isInitialized = true;
      });
      _initCompleter.complete();
    }
  }

  Future<void> _startSmartPreloading() async {
    if (_reels.isEmpty) return;
    
    // Preload videos using the enhanced service
    await _videoService.preloadVideos(
      _reels,
      currentIndex: _currentIndex,
      currentMood: _currentMood,
    );
  }

  void _startBackgroundOptimizations() {
    // Start periodic preloading timer
    _preloadTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Continuous background preloading
      _videoService.preloadVideos(
        _reels,
        currentIndex: _currentIndex,
        currentMood: _currentMood,
      );
    });

    // Start background refresh timer (check every 5 minutes)
    _backgroundRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      _checkAndRefreshStaleData();
    });
  }

  /// Check if cached data is stale and refresh in background
  Future<void> _checkAndRefreshStaleData() async {
    try {
      // Check if we should refresh from network (based on ReelsCacheService logic)
      final shouldRefresh = await ReelsCacheService.shouldRefreshFromNetwork();
      
      if (shouldRefresh && !_isLoading && !_isRefreshing) {
        debugPrint('Background refresh: Cached data is stale, fetching fresh reels');
        
        // Fetch fresh reels in background without showing loading UI
        final freshReels = await _fetchFreshReelsFromFirebase();
        
        if (freshReels.isNotEmpty && freshReels.length != _reels.length) {
          // Cache the fresh reels
          await ReelsCacheService.cacheReels(freshReels, _currentMood);
          
          // Update reels silently if user is at the beginning of the feed
          if (_currentIndex <= 2) {
            setState(() {
              _reels = freshReels;
              _lastDocument = null; // Reset pagination
              _hasMoreReels = true;
            });
            
            // Restart preloading for fresh content
            await _startSmartPreloading();
            debugPrint('Background refresh: Updated feed with ${freshReels.length} fresh reels');
          } else {
            debugPrint('Background refresh: Fresh reels cached, will be available on next refresh');
          }
        }
      }
    } catch (e) {
      // Silently handle background refresh errors
      debugPrint('Background refresh failed: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _videoService.pauseAll();
        break;
      case AppLifecycleState.resumed:
        // Resume will be handled by individual video items
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _onPageChanged(int index) {
    if (!mounted) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    // Update cubit
    _reelsCubit.onPageChanged(index);
    
    // Trigger smart preloading for new position
    _videoService.preloadVideos(
      _reels,
      currentIndex: index,
      currentMood: _currentMood,
    );
    
    // Load more reels if approaching end
    if (index >= _reels.length - 3) {
      _loadMoreReels();
    }
  }

  Future<void> _loadMoreReels() async {
    if (_isLoadingMore || !_hasMoreReels) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      debugPrint('Loading more reels from Firebase, current count: ${_reels.length}');
      
      final moreReels = await ReelsService.fetchReelsByMood(
        mood: _currentMood,
        lastDoc: _lastDocument,
        limit: 10, // Load 10 more reels
        onLastDoc: (doc) => _lastDocument = doc,
        onHasMore: (hasMore) => _hasMoreReels = hasMore,
      );
      
      if (moreReels.isNotEmpty) {
        setState(() => _reels.addAll(moreReels));
        
        // Cache the updated reels
        await ReelsCacheService.cacheReels(_reels, _currentMood);
        debugPrint('Loaded ${moreReels.length} more reels, total: ${_reels.length}');
      } else {
        debugPrint('No more reels available for mood: $_currentMood');
      }
      
    } catch (e) {
      debugPrint('Failed to load more reels: $e');
      
      // Try fallback method
      try {
        final fallbackReels = await ReelsService.fetchMoreReels(
          lastDoc: _lastDocument,
          limit: 5,
          onLastDoc: (doc) => _lastDocument = doc,
          onHasMore: (hasMore) => _hasMoreReels = hasMore,
        );
        
        if (fallbackReels.isNotEmpty) {
          setState(() {
            _reels.addAll(fallbackReels);
          });
          await ReelsCacheService.cacheReels(_reels, _currentMood);
          debugPrint('Fallback loaded ${fallbackReels.length} reels');
        }
      } catch (fallbackError) {
        debugPrint('Fallback load more also failed: $fallbackError');
      }
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Widget _buildVideoFeed() {
    if (!_isInitialized) {
      return _buildLoadingView();
    }

    if (_reels.isEmpty) {
      return _buildEmptyView();
    }


    return PreloadPageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _reels.length,
      preloadPagesCount: 2, // Preload 2 pages ahead
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        final reel = _reels[index];
        final isCurrentItem = index == _currentIndex;
        return EnhancedVideoFeedItem(
          key: ValueKey(reel.reelID),
          reel: reel,
          comingFromHome: true,
          shouldAutoPlay: isCurrentItem,
          isCurrentItem: isCurrentItem,
          onTap: () => _onVideoTap(index),
          onPlayStateChanged: (isPlaying) => _onPlayStateChanged(index, isPlaying),
        );
      },
    );
  }

  void _onVideoTap(int index) {
    // Handle video tap - you can add navigation to comments, etc.
    debugPrint('Video tapped at index: $index');
  }

  void _onPlayStateChanged(int index, bool isPlaying) {
    // Handle play state changes
    debugPrint('Video at index $index is ${isPlaying ? 'playing' : 'paused'}');
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            Text(
              'No videos available',
              style: AppTextStyles.headingTextStyle2.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again',
              style: AppTextStyles.smallTextStyle.copyWith(
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _initializeVideoFeed(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Retry',
                style: AppTextStyles.buttonTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App title
            Text(
              AppConstants.appTitle,
              style: AppTextStyles.headingTextStyle2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Performance indicator (debug mode only)
            /*if (kDebugMode)
              _buildPerformanceIndicator(),*/
          ],
        ),
      ),
    );
  }

 /* Widget _buildPerformanceIndicator() {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.value(_videoService.getPerformanceStats()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final stats = snapshot.data!;
        final avgLoadTime = stats['averageLoadTime'];
        // final bufferEvents = stats['totalBufferEvents'] as int;
        
        Color indicatorColor = Colors.green;
        if (avgLoadTime > 1000) {
          indicatorColor = Colors.red;
        } else if (avgLoadTime > 500) {
          indicatorColor = Colors.orange;
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${avgLoadTime.toInt()}ms',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video feed
          _buildVideoFeed(),
          
          // Header with title and performance indicator
          _buildHeader(),


          // Loading overlay
          if (_isLoading || _isRefreshing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                    if (_isRefreshing) ...[ 
                      const SizedBox(height: 16),
                      Text(
                        'Refreshing feed...',
                        style: AppTextStyles.regularTextStyle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _preloadTimer?.cancel();
    _backgroundRefreshTimer?.cancel();
    _pageController.dispose();
    _videoService.dispose();
    super.dispose();
  }
}
