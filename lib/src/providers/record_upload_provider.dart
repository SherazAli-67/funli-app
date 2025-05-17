import 'package:flutter/material.dart';

class RecordUploadProvider extends ChangeNotifier{
  bool isRecording = false;
  bool isRecorded = false;
  String? recordedPath;


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

}