import 'package:cloud_firestore/cloud_firestore.dart';

class ReportContentModel {
  final String reason;
  final String description;
  final Timestamp timestamp;

  ReportContentModel({
    required this.reason,
    required this.description,
    required this.timestamp,
  });

  // Convert model to Map for Firebase or local storage
  Map<String, dynamic> toMap() {
    return {
      'reason': reason,
      'description': description,
      'timestamp': timestamp,
    };
  }

  // Create model from Map (e.g., from Firebase document)
  factory ReportContentModel.fromMap(Map<String, dynamic> map) {
    return ReportContentModel(
      reason: map['reason'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}