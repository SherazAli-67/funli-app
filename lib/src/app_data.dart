
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/testing/social_media/social_api_service.dart';

class AppData {
  static List<String> interestList = [
    '🍿 Entertainment', '🎮 Gaming', '🎨 Art', '🙈 Animals', '😁 Comedy', '💃 Dance', '💄 Beauty', '🎶 Music',
    '🍸 Food & Drink', '🏏 Sports', '🧩 DIY', '🧪 Science & Education', '✈️ Travel', '👨‍👩‍👧‍👦 Family', '🎥 Anime & Movie',
    '⚙️ Technology', '⚽ Outdoors', '🕌 Culture', '❤️‍🩹 Health', '💭 Comics'
  ];


  static List<UserSuggestion> suggestions = [
    UserSuggestion(id: "1", username: "Sheraz Ali", displayName: "sherazali", avatarUrl: "https://plus.unsplash.com/premium_photo-1671656349322-41de944d259b?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fHBlcnNvbnxlbnwwfHwwfHx8MA%3D%3D", verified: true),
    UserSuggestion(id: "2", username: "Syed Hamza", displayName: "hamzali", avatarUrl: "https://images.unsplash.com/flagged/photo-1570612861542-284f4c12e75f?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8cGVyc29ufGVufDB8fDB8fHww", verified: true),
    UserSuggestion(id: "3", username: "Isela Trujilo", displayName: "isela", avatarUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cGVyc29ufGVufDB8fDB8fHww", verified: true),
    UserSuggestion(id: "4", username: "Monte Castro", displayName: "montecastro", avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHBlcnNvbnxlbnwwfHwwfHx8MA%3D%3D", verified: false),
  ];

  static List<HashtagSuggestion> hashtags = [
    HashtagSuggestion(tag: "trending", count: 1002),
    HashtagSuggestion(tag: "ai", count: 9878),
    HashtagSuggestion(tag: "reels", count: 555),
    HashtagSuggestion(tag: "bollywood", count: 5666),
    HashtagSuggestion(tag: "dance", count: 111198),
    HashtagSuggestion(tag: "songs", count: 876923),

  ];


  static String getEmojiByMood(String mood){
    switch(mood){
      case 'Happy':
        return AppConstants.happyEmoji;

      case 'Sad':
        return AppConstants.sadEmoji;

      case 'Angry':
        return AppConstants.angryEmoji;

      case 'Laughing':
        return AppConstants.laughingEmoji;

      case 'Crying':
        return AppConstants.cryingEmoji;

      case 'Annoyed':
        return AppConstants.annoyedEmoji;

      default:
        return AppConstants.happyEmoji;
    }
  }

  static List<ReelModel> getReels(){
    String userID = 'RurOyejb8iQERN1R9OqJ81eokg02';
    String reelID = DateTime.now().microsecondsSinceEpoch.toString();

    List<String> urls = [
      'https://videos.pexels.com/video-files/1321208/1321208-sd_640_360_30fps.mp4',
      'https://videos.pexels.com/video-files/3629511/3629511-sd_360_450_24fps.mp4',
      'https://videos.pexels.com/video-files/2759477/2759477-sd_640_360_30fps.mp4',
      'https://videos.pexels.com/video-files/8859849/8859849-sd_360_640_25fps.mp4',
      'https://videos.pexels.com/video-files/3833491/3833491-sd_360_640_30fps.mp4',
      'https://videos.pexels.com/video-files/6924608/6924608-sd_360_640_24fps.mp4',
      'https://videos.pexels.com/video-files/3048183/3048183-sd_640_360_24fps.mp4',
      'https://videos.pexels.com/video-files/6010489/6010489-sd_360_640_25fps.mp4',
      'https://videos.pexels.com/video-files/5667135/5667135-sd_506_960_30fps.mp4',
      'https://videos.pexels.com/video-files/6190918/6190918-sd_360_640_30fps.mp4',
      'https://videos.pexels.com/video-files/6624888/6624888-sd_360_640_30fps.mp4',
      'https://videos.pexels.com/video-files/4199353/4199353-sd_640_360_25fps.mp4',
      'https://videos.pexels.com/video-files/4169986/4169986-sd_640_360_30fps.mp4'
    ];
    return [
      // ReelModel(reelID: reelID, userID: userID, videoUrl: "videoUrl", thumbnailUrl: thumbnailUrl, caption: caption, hashtags: hashtags, mentions: mentions, commentsCount: commentsCount, shareCount: shareCount, moodTag: moodTag, visibility: visibility, createdAt: createdAt)
    ];
  }
}