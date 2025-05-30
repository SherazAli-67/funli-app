import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/notification_service/notification_service.dart';
import 'package:funli_app/src/services/publish_reel_service.dart';
import 'package:video_compress/video_compress.dart';

class RecordUploadProvider extends ChangeNotifier{
  bool isRecording = false;
  bool isRecorded = false;
  String? _recordedPath;
  String _currentMood = 'Happy';
  String videoRecordingDuration = '30s';

  double playbackSpeed = 1;
  bool isMuted = false;

  String? get recordedPath => _recordedPath;
  String get currentMood => _currentMood;
  bool isCompressingVideo = false;

  void toggleRecording(){
    isRecording = !isRecording;
    notifyListeners();
  }

  void setIsRecorded(){
    isRecorded = true;
    notifyListeners();
  }

  void setRecordingPath(String path){
    _recordedPath = path;
    notifyListeners();
  }

  void setRecordingDuration(String duration){
    videoRecordingDuration = duration;
    notifyListeners();
  }

  void setCurrentMood(String mood){
    _currentMood = mood;
    notifyListeners();
  }

  void setRecordedVideoPath(String path){
    _recordedPath = path;
    notifyListeners();
  }
  void setPlaybackSpeed(double playbackSpeed){
    this.playbackSpeed = playbackSpeed;
    notifyListeners();
  }

  void setMuted(bool val){
    isMuted = val;
    notifyListeners();
  }

  void publishReel({required String caption, required String visibility, required VoidCallback navigationCallback}) async{
    isCompressingVideo = true;
    notifyListeners();
    debugPrint("Video size before compression: ${await File(_recordedPath!).length()}");
    File thumbnailPath = await VideoCompress.getFileThumbnail(_recordedPath!);

    final MediaInfo? compressedVideo = await VideoCompress.compressVideo(
      _recordedPath!,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false, // Set true to delete original file
    );

    if (compressedVideo == null || compressedVideo.file == null) {
      throw Exception('Video compression failed');
    }
    isCompressingVideo = false;
    notifyListeners();
    navigationCallback();
    debugPrint("Video size after compression: ${await compressedVideo.file!.length()}");
    String reelID = DateTime.now().microsecondsSinceEpoch.toString();

    String? thumbnailUrl = await PublishReelService.getThumbnailUrl(reelID: reelID, file: thumbnailPath);
     String? videoUrl = await PublishReelService.getReelUploadedUrl(reelID: reelID, file: compressedVideo.file!);

     String userID = FirebaseAuth.instance.currentUser!.uid;
    DateTime createdAt = DateTime.now();
    ReelModel reel = ReelModel(reelID: reelID,
        userID: userID,
        videoUrl: videoUrl!,
        thumbnailUrl: thumbnailUrl!,
        caption: caption,
        hashtags: [],
        mentions: [],
        commentsCount: 0,
        shareCount: 0,
        moodTag: currentMood,
        visibility: visibility,
        createdAt: createdAt);

    bool isUploaded = await PublishReelService.uploadReel(reel: reel);
    if(isUploaded){
      NotificationService.show(
        title: "Upload Completed",
        body: 'Your reel has been uploaded successfully.',
      );
    }
  }

 /* void publishReels() {
    List<ReelModel> reels = AppData.getReels();
    reels.forEach((reel) async {
      bool isUploaded = await PublishReelService.uploadReel(reel: reel);
      if(isUploaded){
        NotificationService.show(
          title: "Upload Completed",
          body: 'Your reel has been uploaded successfully.',
        );
      }
    });
  }*/
}