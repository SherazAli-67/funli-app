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

    final DocumentReference hashtagDocRef = firestore
        .collection(FirebaseConstants.hashtagsCollections)
        .doc(hashtag);

    final DocumentReference reelDocRef = hashtagDocRef
        .collection(FirebaseConstants.reelsCollection)
        .doc(reelID);

    try {
      // Step 1: Check and create hashtag document if it doesn't exist
      final DocumentSnapshot hashtagSnapshot = await hashtagDocRef.get();

      if (!hashtagSnapshot.exists) {
        await hashtagDocRef.set({
          "tag": hashtag,
          "createdAt": FieldValue.serverTimestamp(),
          "reelsCount": 0, // Optional: You can leave this out if you're using the cloud function to update
        });
      }

      // Step 2: Check if reel already exists in the subcollection
      final DocumentSnapshot reelSnapshot = await reelDocRef.get();

      if (!reelSnapshot.exists) {
        await reelDocRef.set({
          "reelID": reelID,
          "createdAt": FieldValue.serverTimestamp(),
        });
      } else {
        // Optional: update existing reel metadata
        await reelDocRef.update({
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      debugPrint(" Reel successfully added to hashtag: $hashtag");
    } catch (e) {
      debugPrint("Error adding reel to hashtag: $e");
    }
  }

  static Future<void> addReelToMood({required String mood, required String reelID, required String userID}) async{

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final DocumentReference moodDocRef = firestore
        .collection(FirebaseConstants.moodsCollection)
        .doc(mood);

    final DocumentReference reelDocRef = moodDocRef
        .collection(FirebaseConstants.reelsCollection)
        .doc(reelID);

    try {
      // Step 1: Check and create hashtag document if it doesn't exist
      final DocumentSnapshot hashtagSnapshot = await moodDocRef.get();

      if (!hashtagSnapshot.exists) {
        await moodDocRef.set({
          "mood": mood,
          "createdAt": FieldValue.serverTimestamp(),
          "reelsCount": 0,
        });
      }

      // Step 2: Check if reel already exists in the subcollection
      final DocumentSnapshot reelSnapshot = await reelDocRef.get();

      if (!reelSnapshot.exists) {
        await reelDocRef.set({
          "reelID": reelID,
          "createdAt": FieldValue.serverTimestamp(),
        });
      } else {
        // Optional: update existing reel metadata
        await reelDocRef.update({
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      debugPrint(" Reel successfully added to mood: $mood");
    } catch (e) {
      debugPrint("Error adding reel to mood: $e");
    }
  }
}