import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funli_app/src/widgets/post_comment_widget.dart';
import 'package:funli_app/src/widgets/post_like_widget.dart';
import 'package:funli_app/src/widgets/post_share_widget.dart';
import 'package:preload_page_view/preload_page_view.dart';
import '../../models/reel_model.dart';
import '../../res/app_colors.dart';
import '../../res/app_constants.dart';
import '../../res/app_textstyles.dart';
import '../../services/enhanced_video_feed_service.dart';
import '../../services/universal_reel_feed_controller.dart';
import '../../services/user_service.dart';
import '../../widgets/enhanced_video_feed_item.dart';

class UpdatedReelsPage extends StatefulWidget {
  const UpdatedReelsPage({
    super.key,
    required this.initialReels,
    required this.selectedIndex,
    this.lastDocument,
    this.comingFrom,
    this.mood,
    this.tag,
    this.userID,
    this.filterContext,
  });

  final List<ReelModel> initialReels;
  final int selectedIndex;
  final DocumentSnapshot? lastDocument;
  final String? comingFrom;
  final String? mood;
  final String? tag;
  final String? userID;
  final Map<String, dynamic>? filterContext;

  @override
  State<UpdatedReelsPage> createState() => _UpdatedReelsPageState();
}

class _UpdatedReelsPageState extends State<UpdatedReelsPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  
  // Controllers and services
  late PreloadPageController _pageController;
  late EnhancedVideoFeedService _videoService;
  late UniversalReelFeedController _feedController;
  
  // State management
  List<ReelModel> _reels = [];
  int _currentIndex = 0;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isRefreshing = false;
  
  // Performance tracking
  final Completer<void> _initCompleter = Completer<void>();
  Timer? _preloadTimer;
  StreamSubscription? _reelsSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _currentIndex = widget.selectedIndex;
    _pageController = PreloadPageController(initialPage: _currentIndex);
    _videoService = EnhancedVideoFeedService();
    
    _initializeReelsFeed();
  }

  Future<void> _initializeReelsFeed() async {
    setState(() => _isLoading = true);

    try {
      // Initialize the enhanced video service
      await _videoService.initialize();
      
      // Create appropriate data source based on source type
      final dataSource = ReelDataSourceFactory.createDataSource(
        comingFrom: widget.comingFrom ?? AppConstants.comingFromMood,
        mood: widget.mood,
        tag: widget.tag,
        userID: widget.userID,
        filterContext: widget.filterContext,
      );
      
      // Initialize universal feed controller
      _feedController = UniversalReelFeedController(dataSource);
      await _feedController.initialize(
        initialReels: widget.initialReels,
        selectedIndex: widget.selectedIndex,
        lastDocument: widget.lastDocument,
      );
      
      // Subscribe to reels updates
      _reelsSubscription = _feedController.reelsStream.listen((reels) {
        if (mounted) {
          setState(() {
            _reels = reels;
          });
          
          // Start smart preloading for new reels
          _startSmartPreloading();
        }
      });
      
      // Wait for initialization
      await _feedController.waitForInitialization();
      
      setState(() {
        _reels = _feedController.reels;
        _isInitialized = true;
        _isLoading = false;
      });
      
      _initCompleter.complete();
      
      // Start background optimizations
      _startBackgroundOptimizations();
      
      // Initial preloading
      await _startSmartPreloading();
      
    } catch (e) {
      debugPrint('Failed to initialize reels feed: $e');
      setState(() => _isLoading = false);
      
      // Fallback to initial reels
      setState(() {
        _reels = widget.initialReels;
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
      currentMood: _getCurrentMoodFromSource(),
    );
  }

  String _getCurrentMoodFromSource() {
    if (widget.comingFrom == AppConstants.comingFromMood && widget.mood != null) {
      return widget.mood!;
    }
    return 'Happy'; // Default mood
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
        currentMood: _getCurrentMoodFromSource(),
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
    
    setState(() => _currentIndex = index);
    
    // Update feed controller
    _feedController.updateCurrentIndex(index);
    
    // Trigger smart preloading for new position
    _videoService.preloadVideos(
      _reels,
      currentIndex: index,
      currentMood: _getCurrentMoodFromSource(),
    );
    
    // Provide haptic feedback for better UX
    HapticFeedback.selectionClick();
  }

  Future<void> _refreshFeed() async {
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

      // Refresh the feed controller
      await _feedController.refreshFeed();
      
      setState(() {
        _currentIndex = 0;
        _isRefreshing = false;
      });

      // Restart smart preloading for fresh content
      await _startSmartPreloading();

      debugPrint('Reels feed refreshed with ${_reels.length} reels');

    } catch (e) {
      debugPrint('Failed to refresh reels feed: $e');
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  Widget _buildReelsFeed() {
    if (!_isInitialized) {
      return _buildLoadingView();
    }

    if (_reels.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      backgroundColor: Colors.black,
      color: AppColors.purpleColor,
      child: PreloadPageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        preloadPagesCount: 2, // Preload 2 pages ahead
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final reel = _reels[index];
          final isCurrentItem = index == _currentIndex;
          
          return _buildReelItem(reel, index, isCurrentItem);
        },
      ),
    );
  }

  Widget _buildReelItem(ReelModel reel, int index, bool isCurrentItem) {
    return Stack(
      children: [
        // Video player
        Positioned.fill(
          child: EnhancedVideoFeedItem(
            key: ValueKey(reel.reelID),
            reel: reel,
            shouldAutoPlay: isCurrentItem,
            isCurrentItem: isCurrentItem,
            onTap: () => _onVideoTap(index),
            onPlayStateChanged: (isPlaying) => _onPlayStateChanged(index, isPlaying),
          ),
        ),

        // Loading indicator for buffering
        if (_isLoading || _isRefreshing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.purpleColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onVideoTap(int index) {
    // Handle video tap - you can add pause/play functionality
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
            const Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            Text(
              'No reels available',
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



  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main reels feed
          _buildReelsFeed(),
          
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
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
    _reelsSubscription?.cancel();
    _pageController.dispose();
    _feedController.dispose();
    _videoService.dispose();
    super.dispose();
  }
}

// Widget for reel interaction buttons (like, comment, share, bookmark)
class ReelInteractionColumn extends StatelessWidget {
  const ReelInteractionColumn({
    super.key,
    required this.reel,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onBookmark,
  });

  final ReelModel reel;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PostLikeWidget(reel: reel),
       PostCommentWidget(reel: reel, comingFromHome: false),
       PostShareWidget(reel: reel, onShareTap: (){},),
       // PostBookmarkWidget(reelID: reel.reelID),
       /* _buildInteractionButton(
          Icons.favorite_outline,
          '${reel.likesCount ?? 0}',
          onLike,
        ),
        const SizedBox(height: 16),
        _buildInteractionButton(
          Icons.comment_outlined,
          '${reel.commentsCount ?? 0}',
          onComment,
        ),
        const SizedBox(height: 16),
        _buildInteractionButton(
          Icons.share_outlined,
          'Share',
          onShare,
        ),
        const SizedBox(height: 16),
        _buildInteractionButton(
          Icons.bookmark_outline,
          '',
          onBookmark,
        ),*/
      ],
    );
  }

}

// Widget for reel information overlay (user info, description, etc.)
class ReelInfoOverlay extends StatelessWidget {
  const ReelInfoOverlay({
    super.key,
    required this.reel,
    required this.onProfileTap,
    required this.onMoodTap,
  });

  final ReelModel reel;
  final VoidCallback onProfileTap;
  final VoidCallback onMoodTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // User info
        FutureBuilder(future: UserService.getUserByID(userID: reel.userID), builder: (ctx, snap){
          if(snap.hasData && snap.requireData != null){
            return GestureDetector(
              onTap: onProfileTap,
              child: Row(
                children: [
                  /*CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      re ?? 'https://via.placeholder.com/100',
                    ),
                  ),*/
                  const SizedBox(width: 8),
                  Text(
                    snap.requireData!.userName,
                    style: AppTextStyles
                        .buttonTextStyle
                        .copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        }),

        
        const SizedBox(height: 8),
        
        // Description
        // if (reel.caption != null && reel.description!.isNotEmpty)
          Text(
            reel.caption,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        
        const SizedBox(height: 4),
        
        // Mood tag
        // if (reel.moodTag != null)
          GestureDetector(
            onTap: onMoodTap,
            child: Text(
              '#${reel.moodTag}',
              style: const TextStyle(
                color: AppColors.purpleColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
