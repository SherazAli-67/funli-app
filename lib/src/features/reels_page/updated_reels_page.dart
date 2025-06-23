import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/reels_page/reel_repository.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
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
  final _pageController = PreloadPageController(initialPage: 0);
  final int _maxCacheSize = 5; // Increased to accommodate preloading of adjacent reels

  late ReelsCubit _cubit;
  List<ReelModel> _videos = [];
  int _currentPage = 0;

  final Map<String, VideoPlayerController> _controllerCache = {};
  final List<String> _accessOrder = [];
  final Set<String> _disposingControllers = {};

  bool _isAppActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videos = widget.initialReels;
    _currentPage = widget.selectedIndex;

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

    // Initialize controller for the selected reel immediately
    _initializeControllerIfNeeded(
      _videos[_currentPage].reelID,
      _videos[_currentPage].videoUrl,
      shouldPlay: true,
    );
    
    // Defer jumpToPage until after first layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppActive = state == AppLifecycleState.resumed;
    if (!_isAppActive) {
      _pauseAllControllers();
    } else {
      _playController(_videos[_currentPage].reelID);
    }
  }

  void _pauseAllControllers() {
    for (final controller in _controllerCache.values) {
      if (controller.value.isInitialized && controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void _initializeControllerIfNeeded(String reelID, String videoUrl, {bool shouldPlay = false}) async {
    if (_controllerCache.containsKey(reelID)) {
      _accessOrder.remove(reelID);
      _accessOrder.insert(0, reelID);

      if (shouldPlay) {
        _playController(reelID);
      }
      return;
    }

    final file = await _cubit.getCachedVideoFile(videoUrl);
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    controller.setLooping(false); // Disable looping to detect video end
    _controllerCache[reelID] = controller;
    _accessOrder.insert(0, reelID);

    // Listen for video end
    controller.addListener(() {
      final bool isEnded = controller.value.position >= controller.value.duration &&
          !controller.value.isPlaying &&
          controller.value.position != Duration.zero;

      if (isEnded && _videos.indexWhere((v) => v.reelID == reelID) == _currentPage) {
        _goToNextReel();
      }
    });

    if (_controllerCache.length > _maxCacheSize) {
      final String lastUsed = _accessOrder.removeLast();
      _disposeController(lastUsed);
    }

    if (shouldPlay) {
      controller.play();
    }

    if (mounted) setState(() {});
  }

  void _disposeController(String reelID) async {
    if (_disposingControllers.contains(reelID)) return;
    _disposingControllers.add(reelID);

    final controller = _controllerCache[reelID];
    await controller?.dispose();
    _controllerCache.remove(reelID);
    _disposingControllers.remove(reelID);
  }

  void _playController(String reelID) {
    final controller = _controllerCache[reelID];
    if (controller != null && controller.value.isInitialized) {
      controller.play();
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
                itemCount: _videos.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  _cubit.onPageChanged(index);
              
                  _initializeControllerIfNeeded(_videos[index].reelID, _videos[index].videoUrl, shouldPlay: true);
                  _playController(_videos[index].reelID);
              
                  // Preload controllers for previous 2 and next 2 reels
                  for (int i = index - 2; i <= index + 2; i++) {
                    if (i >= 0 && i < _videos.length && i != index) {
                      _initializeControllerIfNeeded(_videos[i].reelID, _videos[i].videoUrl, shouldPlay: false);
                    }
                  }
                },
                itemBuilder: (context, index) {
                  final reel = _videos[index];
                  final controller = _controllerCache[reel.reelID];
              
                  return controller != null && controller.value.isInitialized
                      ? RepaintBoundary(
                    child: VideoFeedItem(
                      key: ValueKey(reel.reelID),
                      controller: controller,
                      reel: reel,
                      isComingFromHome: false,
                    ),
                  )
                      : const Center(child: CircularProgressIndicator());
                },
              ),
              Positioned(
                top: 55,
                left: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    IconButton(onPressed: (){
                      context.pop();
                    }, icon:SvgPicture.asset(AppIcons.icArrowBack, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),)),
                    Text(AppConstants.appTitle, style: AppTextStyles.headingTextStyle3.copyWith(color: Colors.white),)
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final controller in _controllerCache.values) {
      controller.dispose();
    }
    _controllerCache.clear();
    _pageController.dispose();
    super.dispose();
  }

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
}
