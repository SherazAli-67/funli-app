import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/reels_page/reel_repository.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/video_audio_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';

import '../../models/reel_model.dart';
import '../main_menu/widgets/video_feed_item.dart';
import 'bloc_cubit/reels_cubit.dart';
import 'bloc_cubit/reels_state.dart';

class UpdatedReelsPage extends StatefulWidget {
  final List<ReelModel> initialReels;
  final int selectedIndex;
  final DocumentSnapshot? lastDocument;
  final String comingFrom;
  final String? userID;
  final String? tag;
  final String? mood;

  const UpdatedReelsPage({
    super.key,
    required this.initialReels,
    required this.selectedIndex,
    this.lastDocument,
    required this.comingFrom,
    this.userID,
    this.mood,
    this.tag,
  });

  @override
  State<UpdatedReelsPage> createState() => _UpdatedReelsPageState();
}

class _UpdatedReelsPageState extends State<UpdatedReelsPage> with WidgetsBindingObserver {
  // Page controller for vertical scrolling
  late PreloadPageController _pageController;
  final int _preloadPageCount = 1; // Preload adjacent pages
  
  // Video management
  final _videoManager = VideoAudioManager();
  late ReelsCubit _cubit;
  List<ReelModel> _videos = [];
  int _currentPage = 0;
  
  // Controller cache
  final Map<String, VideoPlayerController> _controllerCache = {};
  final Set<String> _initializingControllers = {};
  
  // App lifecycle
  bool _isAppActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _videos = widget.initialReels;
    _currentPage = widget.selectedIndex;
    _pageController = PreloadPageController(
      initialPage: _currentPage,
      viewportFraction: 1.0,
    );
    
    _cubit = ReelsCubit(
      ReelsRepository(
        initialReels: widget.initialReels,
        lastDoc: widget.lastDocument,
        userID: widget.userID,
        mood: widget.mood,
        tag: widget.tag,
        comingFrom: widget.comingFrom
      ),
    );
    
    // Initialize the first video after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndPlayVideo(_currentPage);
      _preloadAdjacentVideos(_currentPage);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppActive = state == AppLifecycleState.resumed;
    if (!_isAppActive) {
      _videoManager.pauseAll();
    } else if (_currentPage < _videos.length) {
      _videoManager.playVideo(_videos[_currentPage].reelID);
    }
  }

  /// Initialize a video controller and optionally play it
  Future<void> _initializeAndPlayVideo(int index, {bool shouldPlay = true}) async {
    if (index < 0 || index >= _videos.length) return;
    
    final reel = _videos[index];
    final reelID = reel.reelID;
    
    // Check if already initialized or initializing
    if (_controllerCache.containsKey(reelID) || _initializingControllers.contains(reelID)) {
      if (shouldPlay) {
        await _videoManager.playVideo(reelID);
      }
      return;
    }
    
    // Mark as initializing
    _initializingControllers.add(reelID);
    
    try {
      // Get cached video file
      final file = await _cubit.getCachedVideoFile(reel.videoUrl);
      final controller = VideoPlayerController.file(file);
      
      // Initialize the controller
      await controller.initialize();
      controller.setLooping(false);
      
      // Cache the controller
      _controllerCache[reelID] = controller;
      _videoManager.registerController(reelID, controller);
      
      // Listen for video completion
      controller.addListener(() {
        if (controller.value.position >= controller.value.duration &&
            controller.value.duration > Duration.zero &&
            !controller.value.isPlaying &&
            index == _currentPage) {
          _goToNextReel();
        }
      });
      
      // Play if requested
      if (shouldPlay && index == _currentPage) {
        await _videoManager.playVideo(reelID);
      }
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error initializing video $reelID: $e");
    } finally {
      _initializingControllers.remove(reelID);
    }
  }

  /// Preload videos adjacent to the current page
  void _preloadAdjacentVideos(int currentIndex) {
    // Preload previous and next videos
    for (int i = currentIndex - _preloadPageCount; i <= currentIndex + _preloadPageCount; i++) {
      if (i >= 0 && i < _videos.length && i != currentIndex) {
        _initializeAndPlayVideo(i, shouldPlay: false);
      }
    }
    
    // Clean up distant videos to save memory
    _cleanupDistantVideos(currentIndex);
  }

  /// Clean up video controllers that are far from the current page
  void _cleanupDistantVideos(int currentIndex) {
    final maxDistance = _preloadPageCount + 2;
    final toRemove = <String>[];
    
    for (int i = 0; i < _videos.length; i++) {
      if ((i - currentIndex).abs() > maxDistance) {
        final reelID = _videos[i].reelID;
        if (_controllerCache.containsKey(reelID)) {
          toRemove.add(reelID);
        }
      }
    }
    
    // Remove distant controllers
    for (final reelID in toRemove) {
      _disposeController(reelID);
    }
  }

  /// Dispose a single controller
  void _disposeController(String reelID) {
    final controller = _controllerCache[reelID];
    if (controller != null) {
      _videoManager.unregisterController(reelID);
      controller.dispose();
      _controllerCache.remove(reelID);
    }
  }

  /// Handle page changes
  void _onPageChanged(int index) async {
    if (index == _currentPage) return;
    
    debugPrint("📱 Page changed from $_currentPage to $index");
    
    // Update current page
    final previousPage = _currentPage;
    setState(() => _currentPage = index);
    
    // Notify cubit
    _cubit.onPageChanged(index);
    
    // Play the new video
    await _initializeAndPlayVideo(index);
    
    // Preload adjacent videos
    _preloadAdjacentVideos(index);
  }

  /// Go to the next reel
  void _goToNextReel() {
    final nextIndex = _currentPage + 1;
    if (nextIndex < _videos.length && _pageController.hasClients) {
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReelsCubit, ReelsState>(
      bloc: _cubit,
      builder: (context, state) {
        _videos = state.videos;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PreloadPageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,
                preloadPagesCount: _preloadPageCount,
                itemCount: _videos.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final reel = _videos[index];
                  final controller = _controllerCache[reel.reelID];
                  
                  return controller != null && controller.value.isInitialized
                      ? RepaintBoundary(
                          child: VideoFeedItem(
                            key: ValueKey(reel.reelID),
                            controller: controller,
                            reel: reel,
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                },
              ),
              Positioned(
                top: 55,
                left: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: SvgPicture.asset(
                        AppIcons.icArrowBack,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppConstants.appTitle,
                      style: AppTextStyles.headingTextStyle3.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    // Pause all videos
    _videoManager.pauseAll();
    
    // Dispose all controllers
    for (final controller in _controllerCache.values) {
      controller.dispose();
    }
    _controllerCache.clear();
    
    // Dispose page controller
    _pageController.dispose();
    
    super.dispose();
  }
}
