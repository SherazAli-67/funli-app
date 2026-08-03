
import 'package:firebase_auth/firebase_auth.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_icons.dart';
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

  static List<ReelModel> getReels(){
    String userID = FirebaseAuth.instance.currentUser!.uid;
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
    final List<String> moodCaptions = [
      "Vibes don't lie 💫 #MoodVibes #GoodEnergy #ReelFeels #ChillMode",
      "Feeling unstoppable today 💥 #BossMood #ConfidenceOn #MotivationVibes #GrindTime",
      "Chasing peace, not perfection 🌿 #MentalWellness #InnerPeace #ChillVibes #StayCalm",
      "This is what happy looks like 😄 #HappyMood #JoyfulVibes #SmileMore #PositiveEnergy",
      "Moody but make it aesthetic 🎭 #AestheticMood #MoodyVibes #DeepFeels #VibeCheck",
      "Lost in the moment 🌀 #InTheZone #MindfulLiving #NowPlaying #FeelTheBeat",
      "Just vibin' through life 🎶 #JustVibes #LaidBack #CarefreeMood #FlowState",
      "From chill to thrill in 5 seconds ⚡ #MoodSwitch #HighEnergy #LetsGo #HypeVibes",
      "Serving calm energy today 🌊 #PeacefulMind #SlowLiving #SoftMood #ZenTime",
      "When the mood takes over 🔥 #ExpressYourself #MoodSwing #ReelMood #Unfiltered",
      "Let emotions do the talking 🗣️ #RealTalk #EmotionalVibes #RawMood #HeartOnSleeve",
      "Dancing with my feelings 💃🕺 #DanceTherapy #FeelTheBeat #MoodMovement #GrooveOn",

      "Let emotions do the talking 🗣️ #RealTalk #EmotionalVibes #RawMood #HeartOnSleeve",
    ];

    final List<List<String>> hashtags = [
      ["#Happy",  "Smile", "Laughing"],
      ["#Sad",  "Annoyed",],
      ["#Happy",  "Smile", "Laughing"],
      ["#Angry",  "Sad"],

      ["#Happy",  "Smile", "Laughing"],
      ["#Sad",  "Annoyed",],
      ["#Happy",  "Smile", "Laughing"],
      ["#Angry",  "Sad"],

      ["#Happy",  "Smile", "Laughing"],
      ["#Sad",  "Annoyed",],
      ["#Happy",  "Smile", "Laughing"],
      ["#Angry",  "Sad"],
      ["#Happy",  "Smile", "Laughing"],
    ];
    return List.generate(urls.length, (index){
      return ReelModel(reelID: '${reelID}_$index',
          userID: userID,
          videoUrl: urls[index],
          caption: moodCaptions[index],
          hashtags:  hashtags[index],
          mentions: [],
          commentsCount: 0,
          shareCount: 0,
          moodTag: "Happy",
          visibility: 'Public',
          createdAt: DateTime.now());
    });
  }

  static List<Map<String, String>> get getMoods => [
    {'label': 'Happy', 'emoji': '😊'},
    {'label': 'Excitement', 'emoji': '🤩'},
    {'label': 'Love', 'emoji': '❤️'},
    {'label': 'Confident', 'emoji': '😎'},
    {'label': 'Pride', 'emoji': '🏅'},
    {'label': 'Care', 'emoji': '🤗'},
    {'label': 'Curious', 'emoji': '🤔'},
    {'label': 'Neutral', 'emoji': '😐'},
    {'label': 'Confused', 'emoji': '😕'},
    {'label': 'Bored', 'emoji': '😒'},
    {'label': 'Sad', 'emoji': '😢'},
    {'label': 'Crying', 'emoji': '😭'},
    {'label': 'Fear', 'emoji': '😨'},
    {'label': 'Angry', 'emoji': '😠'},
    {'label': 'Disgust', 'emoji': '🤢'},
    {'label': 'Anxiety', 'emoji': '😰'},
    {'label': 'Contempt', 'emoji': '😤'},
    {'label': 'Embarrassment', 'emoji': '😳'},
    {'label': 'Surprise', 'emoji': '😮'},
  ];

  static String getEmojiByMood(String mood) {
    List<Map<String, String>> map = AppData.getMoods.where((moodData)=> moodData['label']!.toLowerCase() == mood.toLowerCase()).toList();
    if(map.isNotEmpty){
      return map.first['emoji'] ?? '😊';
    }

    return 'Failed';
  }

  static List<Map<String, dynamic>> faqs = [
    {
      "question": "What is the FUNLI app used for?",
      "answer": "FUNLI is a short video platform where users can watch and share reels based on different moods like happy, sad, excited, etc."
    },
    {
      "question": "How does the mood-based feed work?",
      "answer": "You can select your current mood using the Mood Scroll Wheel. The app then shows reels tagged with that mood."
    },
    {
      "question": "Can I upload videos from my device?",
      "answer": "Yes, you can upload videos from your phone. Only .mp4 format is supported for now."
    },
    {
      "question": "How to use FUNLI?",
      "answer": "Select your mood, scroll through the video feed, like or comment on reels, and explore trending content."
    },
    {
      "question": "How to upload a video on FUNLI?",
      "answer": "Tap the '+' button, choose a video from your gallery, add a caption and mood tag, and publish your reel."
    },
  ];

  static List<Map<String, dynamic>> contactUs = [
    {
      "title": "Customer Services",
      "icon": AppIcons.icCustomerServices
    },
    {
      "title": "Whatsapp",
      "icon": AppIcons.icWhatsapp
    },
    {
      "title": "Website",
      "icon": AppIcons.icWebsite
    },
    {
      "title": "Facebook",
      "icon": AppIcons.icFacebook
    },
    {
      "title": "Twitter",
      "icon": AppIcons.icTwitter
    },
    {
      "title": "Instagram",
      "icon": AppIcons.icInstagram
    },
  ];

  static  List<Map<String, dynamic>> reportReasons = [
    {
      "reason": "Misleading Information",
      "description":
      "Hi, I want to report this content as it contains misleading or false information."
    },
    {
      "reason": "Hate Speech or Symbols",
      "description":
      "Hi, I want to report this content as it promotes hate speech, violence, or offensive symbols."
    },
    {
      "reason": "Harassment or Bullying",
      "description":
      "Hi, I want to report this content as it involves harassment, threats, or bullying."
    },
    {
      "reason": "Sexual Content",
      "description":
      "Hi, I want to report this content as it includes sexually explicit or inappropriate material."
    },
    {
      "reason": "Violent or Dangerous Acts",
      "description":
      "Hi, I want to report this content as it shows or encourages violent or dangerous behavior."
    },
    {
      "reason": "Spam or Scam",
      "description":
      "Hi, I want to report this content as it appears to be spam, scam, or misleading promotion."
    },
    {
      "reason": "Harmful or Abusive Content",
      "description":
      "Hi, I want to report this content as it may be harmful, abusive, or offensive."
    },
    {
      "reason": "Other",
      "description":
      "Hi, I want to report this content for a reason not listed above."
    },
  ];
}