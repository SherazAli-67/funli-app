import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funli_app/src/res/firebase_constants.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/reel_likes_count.dart';

import '../../models/reel_model.dart';
import '../../res/app_colors.dart';
import '../../res/app_icons.dart';
import '../../res/app_textstyles.dart';
import '../../services/reels_service.dart';

class HashtagReelsGrid extends StatefulWidget {
  final String hashtag;
  const HashtagReelsGrid({super.key, required this.hashtag});

  @override
  State<HashtagReelsGrid> createState() => _HashtagReelsGridState();
}

class _HashtagReelsGridState extends State<HashtagReelsGrid> {
  final List<Map<String, dynamic>> _reels = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  @override
  void initState() {
    super.initState();
    _fetchHashtaggedReels();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300 &&
          !_isLoading &&
          _hasMore) {
        _fetchHashtaggedReels();
      }
    });
  }

  Future<void> _fetchHashtaggedReels() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final query = FirebaseFirestore.instance
          .collection(FirebaseConstants.hashtagsCollections)
          .doc(widget.hashtag)
          .collection(FirebaseConstants.reelsCollection)
          // .orderBy("createdAt", descending: true)
          .limit(10);

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
      }
    } catch (e) {
      debugPrint("Error fetching reels: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return _reels.isEmpty && _isLoading
        ? LoadingWidget()
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
          return LoadingWidget();
        }
        ReelModel reel = ReelModel.fromMap( _reels[index]);
        final thumbnailUrl = reel.thumbnailUrl ?? AppIcons.icDummyImgUrl;

        return GestureDetector(
          onTap: () {
            // open reel detail page if needed
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(thumbnailUrl),
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
                          backgroundImage: CachedNetworkImageProvider(AppIcons.icDummyImgUrl),
                        ),
                      ),
                      Expanded(child: Text('User name', style: AppTextStyles.smallTextStyle.copyWith(color: Colors.white),))
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
                        child: Center(child: Icon(Icons.play_arrow_rounded, ),),
                      ),
                      Expanded(
                          child: FutureBuilder(future: ReelsService.getReelLikesCount(reelID: reel.reelID),
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
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}