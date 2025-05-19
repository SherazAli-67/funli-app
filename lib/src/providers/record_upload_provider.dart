import 'package:flutter/material.dart';

class RecordUploadProvider extends ChangeNotifier{
  bool isRecording = false;
  bool isRecorded = false;
  String? _recordedPath;
  String videoRecordingDuration = '30s';

  String currentMood = 'Happy';
  double playbackSpeed = 1;
  bool isMuted = false;

  String? get recordedPath => _recordedPath;
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

  void changeMood(String mood){
    currentMood = mood;
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
}