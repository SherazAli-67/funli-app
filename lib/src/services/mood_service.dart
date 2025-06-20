import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class MoodService {
  static final CollectionReference _moodCollectionRef =  FirebaseFirestore.instance.collection(FirebaseConstants.moodsCollection);

  static Future<Map<String, dynamic>> getReelsByMood({required String mood})async{
    DocumentSnapshot? lastDocument;
    List<ReelModel> reels = [];
    QuerySnapshot querySnapshot = await _moodCollectionRef
        .doc(mood)
        .collection(FirebaseConstants.reelsCollection).orderBy(
        'createdAt', descending: true).limit(5)
        .get();
    lastDocument = querySnapshot.docs.last;
    List<String> reelIDs = querySnapshot.docs.map((doc)=> doc.id).toList();

    for (var reelID in reelIDs) {
      DocumentSnapshot docSnap = await FirebaseFirestore.instance
          .collection(FirebaseConstants.reelsCollection)
          .doc(reelID)
          .get();
      if(docSnap.exists){
        reels.add(ReelModel.fromMap(docSnap.data() as Map<String, dynamic>));
      }
    }

    return {
      'reels' : reels,
      'lastDocument' : lastDocument
    };
  }
}