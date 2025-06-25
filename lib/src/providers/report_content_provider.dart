import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/report_content_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class ReportContentProvider extends ChangeNotifier{
  final CollectionReference _reportsColRef = FirebaseFirestore.instance.collection(FirebaseConstants.reportedContentCollection);
  final CollectionReference _userColRef = FirebaseFirestore.instance.collection(FirebaseConstants.userCollection);
  final CollectionReference _reelsColRef = FirebaseFirestore.instance.collection(FirebaseConstants.reelsCollection);

  String _selectedReason = 'Misleading Information';
  String _selectedReasonDescription = 'I am reporting this content as this contains misleading information';
  bool _isReporting = false;
  String? _lastReportedReelID;
  String get selectedReason => _selectedReason;
  String get selectedReasonDescription => _selectedReasonDescription;
  bool get isReporting => _isReporting;
  String? get lastReportedReelID => _lastReportedReelID;

  void setSelectedReason({required String reason, required String description}){
    _selectedReason = reason;
    _selectedReasonDescription = description;
    notifyListeners();
  }

  Future<void> onReportContentTap({required String reelID}) async {
    _isReporting = true;
    notifyListeners();
    // report content logic

    //Add it to reports collection
    String reportedByUID = FirebaseAuth.instance.currentUser!.uid;
    Timestamp reportTime = Timestamp.now();

    ReportContentModel reportContent = ReportContentModel(
        reason: _selectedReason,
        description: _selectedReasonDescription,
        timestamp: reportTime);

    await _reportsColRef
        .doc(reelID)
        .collection(FirebaseConstants.reports)
        .doc(reportedByUID)
        .set(reportContent.toMap());
    //Add it to user reported content

    debugPrint("Content reported in reports collection");
    await _updateReelsCollection(reelID, reportedByUID);
    debugPrint("Content reported in reels collection");
    _isReporting = false;
    _lastReportedReelID = reelID;
    notifyListeners(); // Notify listeners again after reporting is complete

    debugPrint("_lastReportedReelID updated: $_lastReportedReelID");
    _updateUserReportedContents(userID: reportedByUID, reelID: reelID, reportContent: reportContent);
  }

  Future<void> _updateReelsCollection(String reelID, String userID)async{
    //remove it for the reported by the user, by adding reportedByUsers array
    await _reelsColRef.doc(reelID).update({
      'reportedByUsers': FieldValue.arrayUnion([userID]),
    });
  }

  Future<void> _updateUserReportedContents({required String userID, required String reelID, required ReportContentModel reportContent})async{
    await _userColRef.doc(userID).collection(
        FirebaseConstants.reportedContentCollection).doc(reelID).set(
        reportContent.toMap());

    debugPrint("Content reported in user collection");

  }
}
