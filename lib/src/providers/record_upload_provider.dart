import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/notification_service/notification_service.dart';
import 'package:funli_app/src/services/publish_reel_service.dart';
import 'package:video_compress/video_compress.dart';
import '../helpers/hashtag_helper.dart';

class RecordUploadProvider extends ChangeNotifier{
  bool isRecording = false;
  bool isRecorded = false;
  String? _recordedPath;
  String _currentMood = 'Happy';
  String videoRecordingDuration = '60s';

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

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  Future<void> publishReel({required String caption, required String visibility, required VoidCallback navigationCallback}) async{
    if(recordedPath == null){
      Fluttertoast.showToast(msg: "No video was found to upload");
      return;
    }

    isCompressingVideo = true;
    _uploadProgress = 0.0;
    await VideoCompress.deleteAllCache();
    notifyListeners();
    debugPrint("Video size before compression: ${await File(_recordedPath!).length()}");
   /* FirebaseNotificationsService.show(
      title: "Video Upload",
      body: "Compressing video... (0%)",
    );*/
    File? thumbnailPath;
    try{
      thumbnailPath = await VideoCompress.getFileThumbnail(_recordedPath!);
    }catch(e){
      debugPrint("Error while creating thumbnail: ${e.toString()}");
    }

    MediaInfo? compressedVideo;
    try{
       compressedVideo = await VideoCompress.compressVideo(
        _recordedPath!,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false, // Set true to delete original file
      );
       debugPrint("Video size after compression: ${await compressedVideo?.file!.length()}");
       _uploadProgress = 0.3; // Update progress after compression
       notifyListeners();
       FirebaseNotificationsService.show(
         title: "Uploading Feel Progress",
         body: "Compression complete. Preparing upload... (30%)",
       );
    }catch(e){
      debugPrint("Exception while compressing the video: ${e.toString()}");
    }

    isCompressingVideo = false;
    notifyListeners();
    navigationCallback();

    String reelID = DateTime.now().microsecondsSinceEpoch.toString();
    String? thumbnailUrl;
    String? videoUrl;
    if(thumbnailPath != null){
      thumbnailUrl = await PublishReelService.getThumbnailUrl(reelID: reelID, file: thumbnailPath);
      _uploadProgress = 0.5; // Update progress after thumbnail upload
      notifyListeners();
      /*FirebaseNotificationsService.show(
        title: "Video Upload",
        body: "Thumbnail uploaded. Starting video upload... (50%)",
      );*/
    }

    if(compressedVideo != null){
      videoUrl = await PublishReelService.getReelUploadedUrl(reelID: reelID, file: compressedVideo.file!, onProgress: (progress) {
        _uploadProgress = 0.5 + (progress * 0.5); // Update progress during video upload
        notifyListeners();
        FirebaseNotificationsService.show(
          title: "Uploading Feel Progress",
          body: "Uploading video: ${(progress * 100).toStringAsFixed(0)}% (${(_uploadProgress * 100).toStringAsFixed(0)}% total)",
        );
      });
    }

    if(videoUrl != null){
      String userID = FirebaseAuth.instance.currentUser!.uid;
      DateTime createdAt = DateTime.now();
      ReelModel reel = ReelModel(reelID: reelID,
          userID: userID,
          videoUrl: videoUrl,
          thumbnailUrl: thumbnailUrl,
          caption: caption,
          hashtags: [],
          mentions: [],
          commentsCount: 0,
          shareCount: 0,
          moodTag: currentMood,
          visibility: visibility,
          createdAt: createdAt,
        isMuted: isMuted,
        // playbackSpeed: playbackSpeed
      );


      onUploadReelTap(reel: reel);
    }else{
      Fluttertoast.showToast(msg: "Failed to upload reel, Try again!");
      return;
    }

  }

  Future<void> saveToDrafts({required String caption, required String visibility})async{
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

    bool isUploaded = await PublishReelService.saveToDrafts(reel: reel);
    if(isUploaded){
      FirebaseNotificationsService.show(
        title: "Upload Completed",
        body: 'Your reel has been added to drafts.',
      );
    }
  }

  void _resetData(){
    _currentMood = 'Happy';
    isMuted = false;
    _recordedPath = null;
    playbackSpeed = 1;
    isCompressingVideo = false;
    _uploadProgress = 0;

    notifyListeners();
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


  Future<void> onUploadReelTap({required ReelModel reel, bool isDraft = false}) async {
    bool isUploaded = await PublishReelService.uploadReel(reel: reel);
    _resetData();
    if(isUploaded){
      FirebaseNotificationsService.show(
        title: "Upload Completed",
        body: 'Your reel has been uploaded successfully.',
      );
    }

    //Add reel to user collection
    PublishReelService.addReelToUser(reelID: reel.reelID, mood: reel.moodTag);
    List<String> hashtags = HashtagHelper.extractHashtags(reel.caption);
    for (var hashtag in hashtags) {
      PublishReelService.addReelToHashtag(hashtag: hashtag, reelID: reel.reelID);
    }

    // Add to mood
    PublishReelService.addReelToMood(
      mood: reel.moodTag,
      reelID: reel.reelID,
      userID: reel.userID,
    );
    _resetData();

  }
}
