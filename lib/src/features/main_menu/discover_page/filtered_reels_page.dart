import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/firebase_constants.dart';
import 'package:go_router/go_router.dart';

import '../../../models/filter_model.dart';
import '../../../models/reel_model.dart';
import '../../../models/user_model.dart';
import '../../../res/app_colors.dart';
import '../../../res/app_icons.dart';
import '../../../res/app_textstyles.dart';
import '../../../services/user_service.dart';
import '../../../widgets/loading_widget.dart';

class FilteredReelsPage extends StatefulWidget {
  final ReelFilter filter;

  const FilteredReelsPage({super.key, required this.filter});

  @override
  State<FilteredReelsPage> createState() => _FilteredReelsPageState();
}

class _FilteredReelsPageState extends State<FilteredReelsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ReelModel> _reels = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _fetchReels();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        _hasMore) {
      _fetchReels();
    }
  }

  Future<void> _fetchReels() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Query query = _firestore.collection(FirebaseConstants.reelsCollection).limit(10);

    /// Apply Mood filter
    if (widget.filter.selectedMood != null) {
      String mood =  widget.filter.selectedMood!.name[0].toUpperCase() + widget.filter.selectedMood!.name.substring(1);
      query = query.where('moodTag', isEqualTo: mood);
    }

    /*/// Apply Location filter
    if (widget.filter.location != null && widget.filter.location!.isNotEmpty) {
      query = query.where('location', isEqualTo: widget.filter.location);
    }

    /// Apply Language filter
    if (widget.filter.language != null && widget.filter.language!.isNotEmpty) {
      query = query.where('language', isEqualTo: widget.filter.language);
    }
*/
    /// Apply Popularity sorting
    switch (widget.filter.selectedPopularity) {
      case Popularity.topFeels:
        query = query.orderBy('likesCount', descending: true);
        break;
      case Popularity.newestFeels:
        query = query.orderBy('createdAt', descending: true);
        break;
      case Popularity.mostViewed:
        query = query.orderBy('viewsCount', descending: true);
        break;
      default:
        break;
    }

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();

    debugPrint("Reels found: ${snapshot.size}");
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      _reels = snapshot.docs.map((doc)=> ReelModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } else {
      _hasMore = false;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Selected mood: ${widget.filter.selectedMood?.name}");
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Results", style: AppTextStyles.headingTextStyle3,),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        controller: _scrollController,
        itemCount: _reels.length + 1,
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
          if (index < _reels.length) {
            return _buildReelItem(index);
          } else if (_hasMore) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text("No more reels")),
            );
          }
          },
      )


    );
  }

  Widget _buildReelItem(int index) {
    ReelModel reel = _reels[index];
    final thumbnailUrl = reel.thumbnailUrl ?? AppIcons.icDummyImgUrl;
    return GestureDetector(
      onTap: () {
        // open reel detail page if needed
        context.push(
          RouterEnum.updatedReelsView.routeName,
          extra: {
            'initialReels': _reels,
            'selectedIndex': index,
            'lastDocument': _lastDocument,
            'comingFrom': AppConstants.comingFromSearch,
          },
        );


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
                ],
              ))
        ],
      ),
    );
  }
}