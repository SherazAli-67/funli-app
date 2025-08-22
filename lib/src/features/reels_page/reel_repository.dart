import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/services/reels_service.dart';

import '../../models/reel_model.dart';

abstract class IReelsRepository {
  List<ReelModel> get initialReels;
  DocumentSnapshot? get lastDoc;
  Future<List<ReelModel>> fetchMoreVideos();
}

class ReelsRepository implements IReelsRepository {
  ReelsRepository( {
        required this.initialReels,
        required this.lastDoc,
        required this.comingFrom,
        this.userID,
        this.tag,
        this.mood,
      });

  @override
  final List<ReelModel> initialReels;
  @override
  DocumentSnapshot? lastDoc;
  final String? userID;
  final String? tag;
  final String? mood;
  final String comingFrom;

  @override
  Future<List<ReelModel>> fetchMoreVideos() async {
    List<ReelModel> newReels = [];
    if(comingFrom == AppConstants.comingFromUserProfile){
     newReels = await ReelsService.fetchUserReels(userId: userID!, lastDoc: lastDoc, limit: 2, onLastDoc: (doc)=> lastDoc = doc, onHasMore: (_){});
     return newReels;
    }else if(comingFrom == AppConstants.comingFromMood){
      newReels = await ReelsService.fetchReelsByMood(mood: mood!, lastDoc: lastDoc, limit: 2,onLastDoc: (doc)=> lastDoc = doc, onHasMore: (_){});
    }else if(comingFrom == AppConstants.comingFromHashtag){
      newReels = await ReelsService.fetchReelsByTag(tag: tag!, lastDoc: lastDoc, limit: 2,onLastDoc: (doc)=> lastDoc = doc, onHasMore: (_){},);
    }else if(comingFrom == AppConstants.comingFromBookmark){
      newReels = await ReelsService.fetchUserBookmarkedReels(userId: userID!, lastDoc: lastDoc, limit: 2,onLastDoc: (doc)=> lastDoc = doc, onHasMore: (_){},);
    }else {
      newReels = await ReelsService.fetchMoreReels(lastDoc: lastDoc, limit: 2,onLastDoc: (doc)=> lastDoc = doc, onHasMore: (_){},);
    }

    return newReels;
   /* if (userID != null) query = query.where('userID', isEqualTo: userID);
    if (tag != null) query = query.where('tag', isEqualTo: tag);
    if (mood != null) query = query.where('moodTag', isEqualTo: mood);

    query = query.orderBy('createdAt', descending: true).limit(2);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return [];

    lastDoc = snapshot.docs.last;
    return snapshot.docs
        .map((doc) => ReelModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();*/
  }
}