import 'package:cloud_firestore/cloud_firestore.dart';

class ReelModel {
  final String reelID;
  final String userID;
  final String videoUrl;
  final String? thumbnailUrl;
  final String caption;
  final List<String> hashtags;
  final List<String> mentions;
  final int commentsCount;
  final int shareCount;
  final String moodTag;
  // final double duration;
  final String visibility;
  final DateTime createdAt;
  final bool isMuted;
  final double playbackSpeed;
  final Map<String, dynamic>? location; // e.g., {'lat': 0.0, 'lng': 0.0}


  ReelModel({
    required this.reelID,
    required this.userID,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.caption,
    required this.hashtags,
    required this.mentions,
    required this.commentsCount,
    required this.shareCount,
    required this.moodTag,
    // required this.duration,
    required this.visibility,
    required this.createdAt,
    this.location,
    this.isMuted = false,
    this.playbackSpeed = 1.0
  });

  factory ReelModel.fromMap(Map<String, dynamic> map) {
    // Handle different formats of createdAt
    DateTime createdAtDateTime;
    final createdAtValue = map['createdAt'];
    
    if (createdAtValue is Timestamp) {
      // Handle Firestore Timestamp
      createdAtDateTime = createdAtValue.toDate();
    } else if (createdAtValue is Map) {
      // Handle Map format with seconds and nanoseconds
      final seconds = createdAtValue['seconds'] as int;
      final nanoseconds = createdAtValue['nanoseconds'] as int;
      createdAtDateTime = DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + (nanoseconds / 1000000).round(),
      );
    } else if (createdAtValue is String) {
      // Handle ISO 8601 string
      createdAtDateTime = DateTime.parse(createdAtValue);
    } else {
      // Fallback to current time if format is unknown
      createdAtDateTime = DateTime.now();
    }
    
    return ReelModel(
      reelID: map['reelID'] ?? '',
      userID: map['userID'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      caption: map['caption'] ?? '',
      hashtags: List<String>.from(map['hashtags'] ?? []),
      mentions: List<String>.from(map['mentions'] ?? []),
      commentsCount: map['commentsCount'] ?? 0,
      shareCount: map['shareCount'] ?? 0,
      moodTag: map['moodTag'] ?? '',
      // duration: (map['duration'] ?? 0).toDouble(),
      visibility: map['visibility'] ?? 'public',
      createdAt: createdAtDateTime,
      location: map['location'] != null ? Map<String, dynamic>.from(map['location']) : null,
      isMuted: map['isMuted'] ?? false,
      playbackSpeed: map['playbackSpeed'] ?? 1.0
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reelID': reelID,
      'userID': userID,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'hashtags': hashtags,
      'mentions': mentions,
      'commentsCount': commentsCount,
      'shareCount': shareCount,
      'moodTag': moodTag,
      // 'duration': duration,
      'visibility': visibility,
      'createdAt': createdAt.toIso8601String(), // Convert DateTime to ISO string for JSON serialization
      if (location != null) 'location': location,
      'isMuted' : isMuted,
      'playbackSpeed' : playbackSpeed
    };
  }
}
