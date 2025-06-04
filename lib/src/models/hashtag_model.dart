class HashtagModel {
  final String tag;
  final int reelsCount;


  HashtagModel({
    required this.tag,
    required this.reelsCount,
  });

  Map<String, dynamic> toMap() {
    return {
      "tag" : tag,
      'reelsCount': reelsCount,
    };
  }

  factory HashtagModel.fromMap(Map<String, dynamic> map) {
    return HashtagModel(
      tag: map['tag'],
      reelsCount: map['reelsCount'] ?? 0,
    );
  }
}