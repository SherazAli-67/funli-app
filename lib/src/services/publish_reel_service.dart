import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class PublishReelService {

  static Future<String?> getThumbnailUrl({required String reelID, required File file})async{
    try{
      String userID = FirebaseAuth.instance.currentUser!.uid;
      final thumbnailRef = FirebaseStorage.instance.ref().child('reels/$userID/$reelID/thumbnail.jpg');
      final thumbnailUploadTask = await thumbnailRef.putFile(file);
      return thumbnailUploadTask.ref.getDownloadURL();
    }catch(e){
      debugPrint("Error while getting thumbnail Url: ${e.toString()}");
    }

    return null;
  }

  static Future<String?> getReelUploadedUrl({required String reelID, required File file})async{
    try{
      String userID = FirebaseAuth.instance.currentUser!.uid;
      final videoRef = FirebaseStorage.instance.ref().child('reels/$userID/$reelID/video.mp4');
      final videoUploadTask = await videoRef.putFile(file);
      return videoUploadTask.ref.getDownloadURL();
    }catch(e){
      debugPrint("Error while getting thumbnail Url: ${e.toString()}");
    }

    return null;
  }

  static Future<bool> uploadReel({required ReelModel reel})async{
    bool uploaded = false;
    try{
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.reelsCollection)
          .doc(reel.reelID)
          .set(reel.toMap());

      uploaded = true;

    }catch(e){
      debugPrint("Failed to upload reel: ${e.toString()}");
    }


    return uploaded;
  }

  static Future<void> addReelToHashtag({
    required String hashtag,
    required String reelID,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final DocumentReference reelDocRef = firestore
        .collection(FirebaseConstants.hashtagsCollections)
        .doc(hashtag)
        .collection(FirebaseConstants.reelsCollection)
        .doc(reelID);

    try {
      final DocumentSnapshot snapshot = await reelDocRef.get();

      if (!snapshot.exists) {
        // If the document doesn't exist, create it with a basic map (you can expand this)
        await reelDocRef.set({
          "reelID": reelID,
          "timestamp": FieldValue.serverTimestamp(),
        });
      } else {
        // Optional: Update timestamp or other metadata if needed
        await reelDocRef.update({
          "timestamp": FieldValue.serverTimestamp(),
        });
      }

      print("Reel successfully added to hashtag: $hashtag");
    } catch (e) {
      print("Error adding reel to hashtag: $e");
    }
  }
}