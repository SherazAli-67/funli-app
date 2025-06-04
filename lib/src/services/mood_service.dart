import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/follow_model.dart';
import 'package:funli_app/src/models/hashtag_model.dart';
import 'package:funli_app/src/models/mood_model.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class MoodService {
  static final CollectionReference _moodCollectionRef =  FirebaseFirestore.instance.collection(FirebaseConstants.moodsCollection);

  static Future<List<ReelModel>> getReelsbyMood({required String mood})async{
    List<ReelModel> reels = [];
    QuerySnapshot querySnapshot = await _moodCollectionRef.doc(mood).collection(FirebaseConstants.reelsCollection).get();
    List<String> reelIDs = querySnapshot.docs.map((doc)=> doc.id).toList();

    for (var reelID in reelIDs) {
      DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection(FirebaseConstants.reelsCollection).doc(reelID).get();
      if(docSnap.exists){
        reels.add(ReelModel.fromMap(docSnap.data() as Map<String, dynamic>));
      }
    }
    return reels;
  }
}