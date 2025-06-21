import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

import '../models/reel_model.dart';

class SettingsService {
  static final CollectionReference _userColRef = FirebaseFirestore.instance.collection(FirebaseConstants.userCollection);
  static Stream<bool> isPrivateAccount(String userID){
   return _userColRef.doc(userID).snapshots().map((snapshot){
      final map = snapshot.data() as Map<String, dynamic>;
      UserModel user = UserModel.fromMap(map);
      return user.visibility.value == 'followersOnly';
    });
  }

  static Stream<ProfileVisibility> getProfileVisibility(){
    String userID = FirebaseAuth.instance.currentUser!.uid;
    return _userColRef.doc(userID).snapshots().map((snapshot){
      final map = snapshot.data() as Map<String, dynamic>;
      UserModel user = UserModel.fromMap(map);
      return user.visibility;
    });
  }

  static Future<void> setAccountVisibility({required ProfileVisibility visibility}) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

   await _userColRef.doc(userID).update({
      'visibility' : visibility.value
    });
  }

  static Stream<bool> getSuggestAccountToOthers(){
    String userID = FirebaseAuth.instance.currentUser!.uid;
    return _userColRef.doc(userID).snapshots().map((snapshot){
      final map = snapshot.data() as Map<String, dynamic>;
      bool isPrivateAccount = map['suggestAccountToOthers'] ?? false;
      return isPrivateAccount;
    });
  }

  static Future<void> setSuggestAccountToOthers({required bool isSuggest}) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    await _userColRef.doc(userID).update({
      'suggestAccountToOthers' : isSuggest
    });
  }

  static Stream<bool> getRememberMe(){
    String userID = FirebaseAuth.instance.currentUser!.uid;
    return _userColRef.doc(userID).snapshots().map((snapshot){
      final map = snapshot.data() as Map<String, dynamic>;
      bool rememberMe = map['rememberMe'] ?? true;
      return rememberMe;
    });
  }

  static Future<void> setRememberMe({required bool rememberMe}) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    await _userColRef.doc(userID).update({
      'rememberMe' : rememberMe
    });
  }

  static Stream<bool> getShowAdultContent(){
    String userID = FirebaseAuth.instance.currentUser!.uid;
    return _userColRef.doc(userID).snapshots().map((snapshot){
      final map = snapshot.data() as Map<String, dynamic>;
      bool rememberMe = map['showAdultContent'] ?? false;
      return rememberMe;
    });
  }

  static Future<void> setShowAdultContent({required bool showAdultContent}) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    await _userColRef.doc(userID).update({
      'showAdultContent' : showAdultContent
    });
  }

  static Future<void> reportProblem({required String topic, required String description}) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    String reportID = DateTime.now().microsecondsSinceEpoch.toString();
   await FirebaseFirestore.instance.collection(FirebaseConstants.reportProblemCollection).doc(reportID).set({
      'topic' : topic,
      'description' : description,
      'userID' : userID,
     'timestamp' : Timestamp.now()
    });
  }

  static Future<String> getUserMoodAnalytics() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    List<ReelModel> fetchedReels = [];

    Query query = FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .doc(userID)
        .collection(FirebaseConstants.bookmarksCollection)
        .orderBy("timestamp", descending: true);

    final querySnapshot = await query.get();
    final docs = querySnapshot.docs;

    if (docs.isNotEmpty) {
      for (var doc in docs) {
        final reelID = doc.id;
        final reelSnap = await FirebaseFirestore.instance
            .collection(FirebaseConstants.reelsCollection)
            .doc(reelID)
            .get();

        if (reelSnap.exists) {
          fetchedReels.add(ReelModel.fromMap(reelSnap.data()!));
        }
      }
    }

    // Count moodTags
    Map<String, int> moodCount = {};
    for (var reel in fetchedReels) {
      moodCount[reel.moodTag] = (moodCount[reel.moodTag] ?? 0) + 1;
    }

    // Get mood with highest count
    String mostFrequentMood = 'Happy'; // default
    int maxCount = 0;

    moodCount.forEach((mood, count) {
      if (count > maxCount) {
        mostFrequentMood = mood;
        maxCount = count;
      }
    });

    return mostFrequentMood;
  }

  static Future<Map<String, dynamic>> calculateMoodPercentages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final userId = user.uid;
    final reelsSnapshot = await FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .doc(userId)
        .collection(FirebaseConstants.reelsCollection)
        .get();

    if (reelsSnapshot.docs.isEmpty) {
      return {'percentages': {}, 'totalViews': 0};
    }

    Map<String, int> moodViews = {};
    int totalViews = 0;

    for (var doc in reelsSnapshot.docs) {
      final data = doc.data();
      String reelID = data['reelID'];
      DocumentSnapshot documentSnapshot =  await FirebaseFirestore.instance
          .collection(FirebaseConstants.reelsCollection)
          .doc(reelID).get();
      if(documentSnapshot.exists){
        final map = documentSnapshot.data() as Map<String,dynamic>;
        final moodTag = map['moodTag'] as String? ?? 'Unknown';
        final viewsCount = map['viewsCount'] as int? ?? 0;
        debugPrint("Mood $moodTag viewsCount: $viewsCount");
        moodViews.update(moodTag, (value) => value + viewsCount, ifAbsent: () => viewsCount);
        totalViews += viewsCount;
      }
    }

    if (totalViews == 0) {
      return {'percentages': {}, 'totalViews': 0};
    }
    final percentages = moodViews.map((key, value) => MapEntry(key, (value / totalViews) * 100));
    return {'percentages': percentages, 'totalViews': totalViews};
  }
  
  static Future<Map<String, int>> calculateMoodStreaks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final userId = user.uid;
    final reelsSnapshot = await FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .doc(userId)
        .collection(FirebaseConstants.reelsCollection)
        .get();

    if (reelsSnapshot.docs.isEmpty) {
      return {};
    }

    // List to store all reels with their details
    List<ReelModel> userReels = [];

    // Fetch all reels and their details
    for (var doc in reelsSnapshot.docs) {
      final data = doc.data();
      String reelID = data['reelID'];
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(FirebaseConstants.reelsCollection)
          .doc(reelID).get();
          
      if (documentSnapshot.exists) {
        final map = documentSnapshot.data() as Map<String, dynamic>;
        userReels.add(ReelModel.fromMap(map));
      }
    }

    // Sort reels by creation date (newest first)
    userReels.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Group reels by date (day)
    Map<String, List<ReelModel>> reelsByDate = {};
    for (var reel in userReels) {
      final dateKey = '${reel.createdAt.year}-${reel.createdAt.month.toString().padLeft(2, '0')}-${reel.createdAt.day.toString().padLeft(2, '0')}';
      
      if (!reelsByDate.containsKey(dateKey)) {
        reelsByDate[dateKey] = [];
      }
      reelsByDate[dateKey]!.add(reel);
    }

    // Determine the dominant mood for each day
    Map<String, String> dominantMoodByDate = {};
    for (var entry in reelsByDate.entries) {
      Map<String, int> moodCounts = {};
      
      for (var reel in entry.value) {
        moodCounts.update(reel.moodTag, (value) => value + 1, ifAbsent: () => 1);
      }
      
      // Find the mood with the highest count for this day
      String dominantMood = '';
      int maxCount = 0;
      
      moodCounts.forEach((mood, count) {
        if (count > maxCount) {
          maxCount = count;
          dominantMood = mood;
        }
      });
      
      dominantMoodByDate[entry.key] = dominantMood;
    }

    // Calculate streaks for each mood
    Map<String, int> moodStreaks = {};
    
    // Sort dates chronologically
    List<String> sortedDates = dominantMoodByDate.keys.toList()..sort();
    
    if (sortedDates.isEmpty) {
      return {};
    }
    
    // Initialize with the first day's mood
    String currentMood = dominantMoodByDate[sortedDates.first]!;
    int currentStreak = 1;
    
    // Track the maximum streak for each mood
    moodStreaks[currentMood] = 1;
    
    // Process remaining dates
    for (int i = 1; i < sortedDates.length; i++) {
      final previousDate = DateTime.parse(sortedDates[i-1]);
      final currentDate = DateTime.parse(sortedDates[i]);
      final dayDifference = currentDate.difference(previousDate).inDays;
      
      final todayMood = dominantMoodByDate[sortedDates[i]]!;
      
      // Check if dates are consecutive and mood is the same
      if (dayDifference == 1 && todayMood == currentMood) {
        // Continue the streak
        currentStreak++;
      } else {
        // Reset streak with new mood
        currentMood = todayMood;
        currentStreak = 1;
      }
      
      // Update the maximum streak for this mood
      moodStreaks.update(
        currentMood, 
        (value) => currentStreak > value ? currentStreak : value, 
        ifAbsent: () => currentStreak
      );
    }
    
    return moodStreaks;
  }
}
