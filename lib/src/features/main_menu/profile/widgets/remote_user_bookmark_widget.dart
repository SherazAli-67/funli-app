import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/loading_shimmers/reels_gridview_shimmer.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/firebase_constants.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/reel_likes_count.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_router/router_enum.dart';
import '../../../../services/reels_cache_service.dart';
import '../../../../services/reels_service.dart';

class BookmarkWidget extends StatefulWidget {
  const BookmarkWidget({
    super.key,
    required String userID,
  }) : _userID = userID;

  final String _userID;
  @override
  State<BookmarkWidget> createState() => _BookmarkWidgetState();
}

class _BookmarkWidgetState extends State<BookmarkWidget> {
  final List<Map<String, dynamic>> _reels = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasMore = true;
  final int _limit = 4;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _initializeBookmarks();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && !_isLoading && _hasMore) {
      _fetchBookmarks();
    }
  }

  Future<void> _initializeBookmarks() async {
    // Check for cached bookmarks first
    List<ReelModel> cachedBookmarks = await ReelsCacheService.getCachedUserBookmarks(widget._userID);
    if (cachedBookmarks.isNotEmpty) {
      setState(() {
        _reels.clear();
        _reels.addAll(cachedBookmarks.map((reel) => reel.toMap()).toList());
      });
    }

    // Check if we should refresh from network
    _fetchBookmarks();

  }

  Future<void> _fetchBookmarks({bool isFirstTime = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    bool isCurrentUser = widget._userID == FirebaseAuth.instance.currentUser!.uid;

    Query query = FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .doc(widget._userID)
        .collection(FirebaseConstants.bookmarksCollection)
        .orderBy("timestamp", descending: true);

    if (_lastDocument != null && !isFirstTime) {
      query = query.startAfterDocument(_lastDocument!);
    }

    if(!isCurrentUser){
      query = query.limit(_limit);
    }
    final querySnapshot = await query.get();
    final docs = querySnapshot.docs;

    List<ReelModel> newBookmarks = [];

    if (docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
      for (var doc in querySnapshot.docs) {
        final reelID = doc.id;
        final reelSnap = await FirebaseFirestore.instance
            .collection(FirebaseConstants.reelsCollection)
            .doc(reelID)
            .get();

        if (reelSnap.exists) {
          var reelData = reelSnap.data()!..["id"] = reelSnap.id;
          _reels.add(reelData);
          newBookmarks.add(ReelModel.fromMap(reelData));
        }
      }
    }

    if (newBookmarks.isNotEmpty) {
      // Cache the fetched bookmarks
      await ReelsCacheService.cacheUserBookmarks(newBookmarks, widget._userID);
    }

    setState(() {
      _isLoading = false;
      if (docs.length < _limit) {
        _hasMore = false;
      }
    });
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _lastDocument = null;
      _hasMore = true;
    });

    try {
      // Preload fresh bookmarks without clearing existing ones
      Query query = FirebaseFirestore.instance
          .collection(FirebaseConstants.userCollection)
          .doc(widget._userID)
          .collection(FirebaseConstants.bookmarksCollection)
          .orderBy("timestamp", descending: true)
          .limit(_limit);

      final querySnapshot = await query.get();
      final docs = querySnapshot.docs;

      if (docs.isNotEmpty) {
        DocumentSnapshot? freshLastDoc = querySnapshot.docs.last;
        List<Map<String, dynamic>> fresh = [];
        List<ReelModel> freshBookmarks = [];

        for (var doc in docs) {
          final reelID = doc.id;
          final reelSnap = await FirebaseFirestore.instance
              .collection(FirebaseConstants.reelsCollection)
              .doc(reelID)
              .get();
          if (reelSnap.exists) {
            var reelData = reelSnap.data()!..["id"] = reelSnap.id;
            fresh.add(reelData);
            freshBookmarks.add(ReelModel.fromMap(reelData));
          }
        }

        if (fresh.isNotEmpty) {
          setState(() {
            _reels
              ..clear()
              ..addAll(fresh);
            _lastDocument = freshLastDoc;
            _hasMore = docs.length >= _limit;
          });
          await ReelsCacheService.cacheUserBookmarks(freshBookmarks, widget._userID);
        }
      }
    } finally {
      if (mounted) {
        setState(()=>  _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        key: PageStorageKey('BookmarkedReels'),
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
                child: Center(child: Text("No bookmarks found.")),
              ),
            ),
          if (_reels.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {

                    
                    ReelModel reel = ReelModel.fromMap( _reels[index]);
                    final thumbnailUrl = reel.thumbnailUrl ?? AppIcons.icDummyImgUrl;

                    return GestureDetector(
                      onTap: () {
                        final initialReels = _reels.map((reel)=> ReelModel.fromMap(reel)).toList();

                        context.push(RouterEnum.updatedReelsView.routeName,  extra: {
                          'initialReels': initialReels,
                          'selectedIndex': index,
                          'lastDocument': _lastDocument,
                          'userID' : widget._userID,
                          'comingFrom':AppConstants.comingFromBookmark
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
                              child: FutureBuilder(future: UserService.getUserByID(userID: reel.userID), builder: (ctx, snapshot){
                                if(snapshot.hasData && snapshot.requireData != null){
                                  UserModel user = snapshot.requireData!;
                                  return Row(
                                    spacing: 5,
                                    children: [

                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppColors.purpleColor,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 19,
                                          backgroundImage: CachedNetworkImageProvider(user.profilePicture ?? AppIcons.icDummyImgUrl),
                                        ),
                                      ),
                                      Expanded(child: Text(user.userName, style: AppTextStyles.smallTextStyle.copyWith(color: Colors.white),))
                                    ],
                                  );
                                }
                                return SizedBox();
                              })),
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
                                    child: Center(child: Icon(Icons.play_arrow_rounded, ),),
                                  ),
                                  Expanded(
                                      child: FutureBuilder(future: ReelsService.getReelViewsCount(reelID: reel.reelID),
                                          builder: (ctx, snapshot) {
                                            if(snapshot.hasData && snapshot.requireData > 0){
                                              return ReelLikesCountWidget(count: snapshot.requireData);
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
