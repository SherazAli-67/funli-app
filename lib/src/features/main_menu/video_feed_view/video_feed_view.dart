import 'dart:async';

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
import 'package:funli_app/src/widgets/enhanced_video_feed_item.dart';
import 'package:preload_page_view/preload_page_view.dart';

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
  
  // Performance tracking
  final Completer<void> _initCompleter = Completer<void>();
  Timer? _preloadTimer;

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
      // TODO: Replace with actual Firebase call
      // For now, return fresh data from AppData with some delay to simulate network call
      await Future.delayed(const Duration(milliseconds: 800));
      
      // In a real implementation, this would be:
      // return await ReelsService.getFreshReels(mood: _currentMood, limit: 20);
      
      return AppData.getReels(); // This simulates fresh data
    } catch (e) {
      debugPrint('Failed to fetch from Firebase: $e');
      // Fallback to cached or default data
      return AppData.getReels().take(10).toList();
    }
  }

  Future<void> _initializeVideoFeed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize the enhanced video service
      await _videoService.initialize();
      
      // Get initial mood and reels
      _currentMood = widget.initialMood ?? await ReelsCacheService.getCurrentMood();
      
      // Use provided reels or get from cache/generate
      if (widget.initialReels != null && widget.initialReels!.isNotEmpty) {
        _reels = widget.initialReels!;
      } else {
        // Try to get cached reels first
        _reels = await ReelsCacheService.getCachedReels(_currentMood);
        
        // If no cached reels, use app data reels
        if (_reels.isEmpty) {
          _reels = AppData.getReels();
          // Cache the reels for future use
          await ReelsCacheService.cacheReels(_reels, _currentMood);
        }
      }
      
      // Initialize reels cubit
      _reelsCubit = ReelsCubit(
        ReelsRepository(
          initialReels: _reels,
          mood: _currentMood,
          comingFrom: 'video_feed', lastDoc: null,
        ),
      );
      
      // Start smart preloading
      await _startSmartPreloading();
      
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
      
      _initCompleter.complete();
      
      // Start background optimizations
      _startBackgroundOptimizations();
      
    } catch (e) {
      debugPrint('Failed to initialize video feed: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Fallback to basic reels
      _reels = AppData.getReels().take(10).toList();
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
    try {
      // This would typically fetch from Firebase
      // For now, we'll generate more reels
      final newReels = AppData.getReels();
      
      setState(() {
        _reels.addAll(newReels);
      });
      
      // Cache the new reels
      await ReelsCacheService.cacheReels(_reels, _currentMood);
      
    } catch (e) {
      debugPrint('Failed to load more reels: $e');
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
          color: AppColors.purpleColor,
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
              'Pull down to refresh',
              style: AppTextStyles.smallTextStyle.copyWith(
                color: Colors.white54,
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
            if (kDebugMode)
              _buildPerformanceIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator() {
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
  }

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
                      color: AppColors.purpleColor,
                    ),
                    if (_isRefreshing) ...[ 
                      const SizedBox(height: 16),
                      Text(
                        'Refreshing feed...',
                        style: AppTextStyles.bodyTextStyle.copyWith(
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
    _pageController.dispose();
    _videoService.dispose();
    super.dispose();
  }
}
