import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/loading_shimmers/reel_thumbnail_shimmer_item.dart';
import 'package:funli_app/src/loading_shimmers/reels_gridview_shimmer.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/firebase_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../models/reel_model.dart';
import '../../services/hashtag_mood_cached_reels.dart';
import '../../widgets/reel_grid_item_widget.dart';

class HashtagReelsGrid extends StatefulWidget {
  final String tag;
  final bool isComingFromMood;
  const HashtagReelsGrid({super.key, required this.tag, this.isComingFromMood = false});

  @override
  State<HashtagReelsGrid> createState() => _HashtagReelsGridState();
}

class _HashtagReelsGridState extends State<HashtagReelsGrid> {
  final List<Map<String, dynamic>> _reels = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  // Video controller management for sliding window
  final Map<String, VideoPlayerController> _controllerCache = {};
  final List<String> _accessOrder = [];
  final int _maxCacheSize = 15; // Size of sliding window for controllers
  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeReels();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300 &&
          !_isLoading &&
          _hasMore) {
        _fetchHashtaggedReels();
      }
      _updateVisibleReels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _reels.isEmpty && _isLoading
        ? ReelsGridShimmer()
        : GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _reels.length + (_hasMore ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 9 / 16,
      ),
      itemBuilder: (context, index) {
        if (index >= _reels.length) {
          return ReelThumbnailShimmerItem();
        }
        ReelModel reel = ReelModel.fromMap( _reels[index]);

        return ReelGridItemWidget(
          onTap: () {
            final reels = _reels.map((map) => ReelModel.fromMap(map)).toList();
            // Navigate to UpdatedFeedView to play the reel instantly
            context.push(RouterEnum.updatedReelsView.routeName, extra: {
              'initialReels': reels,
              'selectedIndex': index,
              'lastDocument': _lastDoc,
              'comingFrom': widget.isComingFromMood ? AppConstants.comingFromMood : AppConstants.comingFromHashtag,
              'mood': widget.isComingFromMood ? widget.tag : null,
              'tag': !widget.isComingFromMood ? widget.tag : null,
            });
          },
          reel: reel,
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _disposeAllControllers();
    super.dispose();
  }

  void _disposeAllControllers() {
    for (final controller in _controllerCache.values) {
      controller.dispose();
    }
    _controllerCache.clear();
    _accessOrder.clear();
  }

  void _updateVisibleReels() {
    // Estimate visible items based on scroll position and grid layout
    const int itemsPerRow = 3;
    const double itemHeight = 300; // Approximate height of each grid item
    final double scrollOffset = _scrollController.position.pixels;
    final int firstVisibleRow = (scrollOffset / itemHeight).floor();
    final int firstVisibleIdx = firstVisibleRow * itemsPerRow;
    final int lastVisibleIdx = firstVisibleIdx + (_maxCacheSize * 2); // Buffer for visibility

    setState(() {
      _firstVisibleIndex = firstVisibleIdx.clamp(0, _reels.length - 1);
      _lastVisibleIndex = lastVisibleIdx.clamp(0, _reels.length - 1);
    });

    // Initialize controllers for visible and nearby reels
    for (int i = _firstVisibleIndex; i <= _lastVisibleIndex && i < _reels.length; i++) {
      final reel = ReelModel.fromMap(_reels[i]);
      _initializeControllerIfNeeded(reel.reelID, reel.videoUrl);
    }

    // Clean up controllers outside the sliding window
    _cleanUpControllers();
  }

  void _initializeControllerIfNeeded(String reelID, String videoUrl, {bool shouldPlay = false}) async {
    if (_controllerCache.containsKey(reelID)) {
      _accessOrder.remove(reelID);
      _accessOrder.insert(0, reelID);
      return;
    }

    // TODO: Implement proper video caching and controller initialization.
    // The method getCachedVideoFile is not available in ReelsRepository.
    // For now, controller initialization is disabled to prevent errors.
    debugPrint("Controller initialization for reel $reelID is pending implementation.");
    // Placeholder for future implementation of video caching and initialization.
  }

  void _disposeController(String reelID) async {
    final controller = _controllerCache[reelID];
    if (controller != null) {
      await controller.dispose();
      _controllerCache.remove(reelID);
    }
  }

  void _cleanUpControllers() {
    final List<String> toRemove = [];
    for (final reelID in _controllerCache.keys) {
      final index = _reels.indexWhere((r) => ReelModel.fromMap(r).reelID == reelID);
      if (index < _firstVisibleIndex - _maxCacheSize || index > _lastVisibleIndex + _maxCacheSize) {
        toRemove.add(reelID);
      }
    }
    for (final reelID in toRemove) {
      _disposeController(reelID);
      _accessOrder.remove(reelID);
    }
  }

  Future<void> _initializeReels() async {
    if (widget.isComingFromMood) {
      // Check for cached mood reels and last document
      List<ReelModel> cachedReels = await HashtagMoodCachedReels.getCachedReels(widget.tag);
      DocumentSnapshot? cachedLastDoc = await HashtagMoodCachedReels.getCachedLastDocument(widget.tag);
      if (cachedReels.isNotEmpty) {
        setState(() {
          _reels.clear();
          _reels.addAll(cachedReels.map((reel) => reel.toMap()));
          _lastDoc = cachedLastDoc;
        });
      }
    }
    // Proceed to fetch more reels if needed
    _fetchHashtaggedReels();
    // Initialize controllers for initial visible reels after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateVisibleReels();
    });
  }

  Future<void> _fetchHashtaggedReels() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      late Query query;

      if (widget.isComingFromMood) {
        query = FirebaseFirestore.instance
            .collection(FirebaseConstants.moodsCollection)
            .doc(widget.tag)
            .collection(FirebaseConstants.reelsCollection)
            .orderBy("createdAt", descending: true)
            .limit(5);
      }else{
        query = FirebaseFirestore.instance
            .collection(FirebaseConstants.hashtagsCollections)
            .doc(widget.tag)
            .collection(FirebaseConstants.reelsCollection)
            .orderBy("createdAt", descending: true)
            .limit(5);
      }
      final snapshot = _lastDoc == null
          ? await query.get()
          : await query.startAfterDocument(_lastDoc!).get();

      if (snapshot.docs.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        _lastDoc = snapshot.docs.last;
        for (var doc in snapshot.docs) {
          final reelID = doc.id;
          final reelSnap = await FirebaseFirestore.instance
              .collection(FirebaseConstants.reelsCollection)
              .doc(reelID)
              .get();

          if (reelSnap.exists) {
            _reels.add(reelSnap.data()!..["id"] = reelSnap.id);
          }
        }
        // Cache the fetched reels if coming from mood
        if (widget.isComingFromMood) {
          List<ReelModel> fetchedReels = _reels.map((map) => ReelModel.fromMap(map)).toList();
          await HashtagMoodCachedReels.cacheReels(fetchedReels, widget.tag, _lastDoc);
        }
      }
    } catch (e) {
      debugPrint("Error fetching reels: $e");
    }

    setState(() => _isLoading = false);
  }
}