import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/loading_shimmers/reels_gridview_shimmer.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/firebase_constants.dart';
import 'package:funli_app/src/services/user_service.dart';
import 'package:funli_app/src/widgets/reel_likes_count.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/reels_service.dart';

class DraftFeelsWidget extends StatefulWidget {
  const DraftFeelsWidget({
    super.key,
  });

  @override
  State<DraftFeelsWidget> createState() => _DraftFeelsWidgetState();
}

class _DraftFeelsWidgetState extends State<DraftFeelsWidget> {
  final List<ReelModel> _reels = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  final int _limit = 4;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _initializeDrafts();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && !_isLoading && _hasMore) {
      _fetchDrafts();
    }
  }

  Future<void> _initializeDrafts() async {
    // Check if we should refresh from network
    _fetchDrafts();

  }

  Future<void> _fetchDrafts({bool isFirstTime = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    String currentUID = FirebaseAuth.instance.currentUser!.uid;

    Query query = FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .doc(currentUID)
        .collection(FirebaseConstants.draftsCollection)
        .orderBy("createdAt", descending: true);

    if (_lastDocument != null && !isFirstTime) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final querySnapshot = await query.get();
    final docs = querySnapshot.docs;
    debugPrint("Drafts docs found: ${docs.length}");
    List<ReelModel> newDrafts = docs.map((doc)=> ReelModel.fromMap(doc.data() as Map<String,dynamic>)).toList();
    _reels.addAll(newDrafts);
    setState(() {
      _isLoading = false;
      if (docs.length < _limit) {
        _hasMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_reels.isEmpty && _isLoading) {
      return ReelsGridShimmer();
    }

    if (_reels.isEmpty) {
      return const Center(child: Text("You have no feel in Drafts"));
    }

    return CustomScrollView(
      key: PageStorageKey('DraftReels'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {

                
                ReelModel reel =_reels[index];
                final thumbnailUrl = reel.thumbnailUrl ?? AppIcons.icDummyImgUrl;

                return GestureDetector(
                  onTap: (){
                    context.push(RouterEnum.publishDraftView.routeName, extra: {
                      'reel': reel,
                    });
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
                                    backgroundColor: AppColors.primaryColor,
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
    );

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


}
