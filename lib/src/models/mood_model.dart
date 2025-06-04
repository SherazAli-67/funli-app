class MoodModel {
  final String mood;
  final int reelsCount;


  MoodModel({
    required this.mood,
    required this.reelsCount,
  });

  Map<String, dynamic> toMap() {
    return {
      "mood" : mood,
      'reelsCount': reelsCount,
    };
  }

  factory MoodModel.fromMap(Map<String, dynamic> map) {
    return MoodModel(
      mood: map['mood'],
      reelsCount: map['reelsCount'] ?? 0,
    );
  }
}