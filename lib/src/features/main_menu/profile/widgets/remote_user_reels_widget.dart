import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/loading_shimmers/reels_gridview_shimmer.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/reel_likes_count.dart';
import 'package:go_router/go_router.dart';

import '../../../../services/reels_cache_service.dart';
import '../../../../services/reels_service.dart';

class RemoteUserReelsWidget extends StatefulWidget {
  const RemoteUserReelsWidget({
    super.key,
    required String userID,
    String? userName,
    String? profilePicture
  })
      : _userID = userID,
        _userName = userName,
        _profilePicture = profilePicture;

  final String _userID;
  final String? _userName;
  final String? _profilePicture;

  @override
  State<RemoteUserReelsWidget> createState() => _RemoteUserReelsWidgetState();
}

class _RemoteUserReelsWidgetState extends State<RemoteUserReelsWidget> {
  final List<ReelModel> _reels = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasMore = true;
  final int _limit = 5;
  DocumentSnapshot? _lastDocument;


  @override
  void initState() {
    super.initState();
    _initializeReels();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400 && _hasMore) {
      debugPrint("fetching new reels");
      _fetchReels();
    }
  }

  Future<void> _initializeReels() async {
    // Check for cached reels first
    List<ReelModel> cachedReels = await ReelsCacheService.getCachedUserReels(widget._userID);
    if (cachedReels.isNotEmpty) {
      setState(() {
        _reels.clear();
        _reels.addAll(cachedReels);
      });
    }

    // Always attempt to fetch from network to ensure latest data
    // bool shouldRefresh = await ReelsCacheService.shouldRefreshUserReelsFromNetwork(widget._userID);
    // String currentUID = FirebaseAuth.instance.currentUser!.uid;
    _fetchReels();
  }

  Future<void> _fetchReels() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    bool isCurrentUser = widget._userID == FirebaseAuth.instance.currentUser!.uid;
    final newReels = await ReelsService.fetchUserReels(
      userId: widget._userID,
      lastDoc: _lastDocument,
      limit: _limit,
      onLastDoc: (doc) => _lastDocument = doc,
      onHasMore: (has) => _hasMore = has,
      comingFromProfile: isCurrentUser
    );

    if (newReels.isNotEmpty) {
      // Filter out duplicates by checking reelID
      final existingReelIds = _reels.map((reel) => reel.reelID).toSet();
      final uniqueNewReels = newReels.where((reel) => !existingReelIds.contains(reel.reelID)).toList();
      if (uniqueNewReels.isNotEmpty) {
        _reels.addAll(uniqueNewReels);
        // Cache only the unique fetched reels
        await ReelsCacheService.cacheUserReels(uniqueNewReels, widget._userID);
      }

    }
    _isLoading = false;
    setState((){});
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _lastDocument = null;
      _hasMore = true;
    });

    try {
      bool isCurrentUser = widget._userID == FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot? freshLastDoc;
      bool freshHasMore = true;
      final freshReels = await ReelsService.fetchUserReels(
          userId: widget._userID,
          lastDoc: null,
          limit: _limit,
          onLastDoc: (doc) => freshLastDoc = doc,
          onHasMore: (has) => freshHasMore = has,
          comingFromProfile: isCurrentUser);

      if (freshReels.isNotEmpty) {
        final freshIds = freshReels.map((r) => r.reelID).toSet();
        final uniqueFresh = freshReels.where((r) => freshIds.contains(r.reelID)).toList();
        setState(() {
          _reels
            ..clear()
            ..addAll(uniqueFresh);
          _lastDocument = freshLastDoc;
          _hasMore = freshHasMore;
        });
        await ReelsCacheService.cacheUserReels(uniqueFresh, widget._userID);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        key: PageStorageKey('RemoteUserReels'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (_reels.isEmpty && _isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ReelsGridShimmer(),
              ),
            ),
          if (_reels.isEmpty && !_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: Text("No reels found.")),
              ),
            ),
          if (_reels.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 65),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {

                        ReelModel reel = _reels[index];
                        final thumbnailUrl = reel.thumbnailUrl ?? AppIcons.icDummyImgUrl;

                        return GestureDetector(
                          onTap: () {
                            context.push(RouterEnum.updatedReelsView.routeName, extra: {
                              'initialReels': _reels,
                              'selectedIndex': index,
                              'lastDocument': _lastDocument,
                              'comingFrom': AppConstants.comingFromUserProfile,
                              'userID': FirebaseAuth.instance.currentUser!.uid,
                            },);
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(thumbnailUrl),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                              ),
                              if(widget._userID != FirebaseAuth.instance.currentUser!.uid)
                              Positioned(
                                  top: 10,
                                  left: 5,
                                  right: 5,
                                  child: Row(
                                    spacing: 5,
                                    children: [

                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppColors.purpleColor,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 19,
                                          backgroundImage: CachedNetworkImageProvider(
                                              widget._profilePicture ?? AppIcons.icDummyImgUrl),
                                        ),
                                      ),
                                      Expanded(child: Text(widget._userName ?? '',
                                        style: AppTextStyles.smallTextStyle.copyWith(
                                            color: Colors.white),))
                                    ],
                                  )),
                              Positioned(
                                  bottom: 10,
                                  left: 10,
                                  right: 0,
                                  child: Row(
                                    spacing: 5,
                                    children: [

                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.white,
                                        child: Center(child: Icon(Icons.play_arrow_rounded,),),
                                      ),
                                      Expanded(
                                          child: FutureBuilder(
                                              future: ReelsService.getReelViewsCount(
                                                  reelID: reel.reelID),
                                              builder: (ctx, snapshot) {
                                                if (snapshot.hasData &&
                                                    snapshot.requireData > 0) {
                                                  return ReelLikesCountWidget(
                                                      count: snapshot.requireData);
                                                }

                                                return ReelLikesCountWidget();
                                              }))
                                    ],
                                  ))
                            ],
                          ),
                        );
                      }, // your grid item
                  childCount: _reels.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                  childAspectRatio: 9 / 16,
                ),
              ),
            ),
        ],
      ),
    );

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
