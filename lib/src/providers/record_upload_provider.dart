import 'package:flutter/material.dart';

class RecordUploadProvider extends ChangeNotifier{
  bool isRecording = false;
  bool isRecorded = false;
  String? recordedPath;
  String videoRecordingDuration = '30s';

  String currentMood = 'Happy';

  void toggleRecording(){
    isRecording = !isRecording;
    notifyListeners();
  }

  void setIsRecorded(){
    isRecorded = true;
    notifyListeners();
  }

  void setRecordingPath(String path){
    recordedPath = path;
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
}