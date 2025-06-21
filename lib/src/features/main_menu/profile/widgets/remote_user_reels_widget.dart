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
  bool _hasMore = true;
  final int _limit = 4;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _initializeReels();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300 && !_isLoading &&
        _hasMore) {
      _fetchReels();
    }
  }

  Future<void> _initializeReels() async {
    // Check for cached reels first
    List<ReelModel> cachedReels = await ReelsCacheService.getCachedUserReels(
        widget._userID);
    if (cachedReels.isNotEmpty) {
      setState(() {
        _reels.clear();
        _reels.addAll(cachedReels);
      });
    }

    // Check if we should refresh from network
    bool shouldRefresh = await ReelsCacheService
        .shouldRefreshUserReelsFromNetwork(widget._userID);
    if (shouldRefresh) {
      _fetchReels();
    }
  }

  Future<void> _fetchReels() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final newReels = await ReelsService.fetchUserReels(
      userId: widget._userID,
      lastDoc: _lastDocument,
      limit: _limit,
      onLastDoc: (doc) => _lastDocument = doc,
      onHasMore: (has) => _hasMore = has,
    );

    if (newReels.isNotEmpty) {
      _reels.addAll(newReels);
      // Cache the fetched reels
      await ReelsCacheService.cacheUserReels(newReels, widget._userID);
    }

    setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    if (_reels.isEmpty && _isLoading) {
      return ReelsGridShimmer();
    }

    if (_reels.isEmpty) {
      return const Center(child: Text("No reels found."));
    }

    return CustomScrollView(
      key: PageStorageKey('RemoteUserReels'),
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == _reels.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
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
              childCount: _reels.length + (_hasMore ? 1 : 0),
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
    );

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}