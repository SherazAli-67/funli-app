import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_constants.dart';

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
          .collection(AppConstants.reelsCollection)
          .doc(reel.reelID)
          .set(reel.toMap());
      uploaded = true;
    }catch(e){
      debugPrint("Failed to upload reel: ${e.toString()}");
    }


    return uploaded;
  }
}