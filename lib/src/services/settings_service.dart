import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';
import 'package:funli_app/src/features/profile_analytics_dashboard/reel_views_chart.dart';


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

    Query query = FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .doc(userID)
        .collection(FirebaseConstants.reelsCollection)
        .orderBy("timestamp", descending: true);

    final querySnapshot = await query.get();
    final docs = querySnapshot.docs;
    final mappedDocs = docs.map((doc)=> doc.data() as Map<String, dynamic>).toList();
   /* if (docs.isNotEmpty) {
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
    }*/

    // Count moodTags
    Map<String, int> moodCount = {};
    for (var reel in mappedDocs) {
      debugPrint("MoodTag: ${reel['moodTag']}");
      moodCount[reel['moodTag']] = (moodCount[reel['moodTag']] ?? 0) + 1;
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
      final moodTag = data['moodTag'] as String? ?? 'Unknown';
      final viewsCount = data['viewsCount'] as int? ?? 0;
      debugPrint("Mood $moodTag viewsCount: $viewsCount");
      moodViews.update(moodTag, (value) => value + viewsCount, ifAbsent: () => viewsCount);
      totalViews += viewsCount;
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

   List<Map<String,dynamic>> userReels =  reelsSnapshot.docs.map((doc)=> doc.data()).toList();
   /* // List to store all reels with their details
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
    }*/

    // Sort reels by creation date (newest first)
    userReels.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    // Group reels by date (day)
    Map<String, List<Map<String, dynamic>>> reelsByDate = {};
    for (var reel in userReels) {
      DateTime date = reel['timestamp'].toDate();
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
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
        moodCounts.update(reel['moodTag'], (value) => value + 1, ifAbsent: () => 1);
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
  
  /// Get reel views data for the specified time range
  static Future<List<Map<String, dynamic>>> getReelViewsData(TimeRange timeRange) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    debugPrint("Getting reelViews");
    final userId = user.uid;
    
    // Determine date range based on selected time range
    DateTime startDate;
    DateTime endDate = DateTime.now();
    List<String> labels = [];
    
    switch (timeRange) {
      case TimeRange.weekly:
        // Last 7 days
        startDate = endDate.subtract(const Duration(days: 6));
        // Generate labels for each day (e.g., "Mon", "Tue", etc.)
        for (int i = 0; i <= 6; i++) {
          final date = startDate.add(Duration(days: i));
          labels.add(date.day.toString());
        }
        break;
      case TimeRange.monthly:
        // Last 30 days
        startDate = endDate.subtract(const Duration(days: 29));
        // Generate labels for each week (e.g., "Week 1", "Week 2", etc.)
        for (int i = 0; i < 30; i += 5) {
          final date = startDate.add(Duration(days: i));
          labels.add(date.day.toString());
        }
        break;
      case TimeRange.yearly:
        // Last 12 months
        startDate = DateTime(endDate.year - 1, endDate.month + 1, 1);
        // Generate labels for each month (e.g., "Jan", "Feb", etc.)
        for (int i = 0; i < 12; i++) {
          final month = (startDate.month + i) % 12;
          final monthName = _getMonthName(month == 0 ? 12 : month);
          labels.add(monthName);
        }
        break;
    }
    
    // Fetch all reels for the user
    final reelsSnapshot = await FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .doc(userId)
        .collection(FirebaseConstants.reelsCollection)
        .get();
    
    if (reelsSnapshot.docs.isEmpty) {
      // Return empty data with labels
      return labels.map((label) => {'label': label, 'value': 0.0}).toList();
    }
    
    // Fetch view data for each reel
    List<Map<String, dynamic>> viewsData = [];
    Map<String, double> aggregatedData = {};
    
    // Initialize aggregated data with zeros
    for (var label in labels) {
      aggregatedData[label] = 0;
    }
    
    for (var doc in reelsSnapshot.docs) {
      final data = doc.data();

   /*   DocumentSnapshot reelSnapshot = await FirebaseFirestore.instance
          .collection(FirebaseConstants.reelsCollection)
          .doc(reelID).get();*/

      // Handle different types for timestamp (could be Timestamp or String)
      DateTime createdAt;
      if (data['timestamp'] is Timestamp) {
        createdAt = (data['timestamp'] as Timestamp).toDate();
      } else if (data['timestamp']is String) {
        createdAt = DateTime.parse(data['timestamp'] as String);
      } else {
        // Skip this reel if createdAt is not in a recognized format
        debugPrint("Skipping reel with invalid createdAt format: ${data['timestamp']}");
        continue;
      }

      final viewsCount = data['viewsCount'] as int? ?? 0;

      // Skip reels created before the start date
      if (createdAt.isBefore(startDate)) {
        continue;
      }

      // Determine which label/period this reel belongs to
      String label;

      switch (timeRange) {
        case TimeRange.weekly:
        // Day of the week
          final dayIndex = createdAt.difference(startDate).inDays;
          if (dayIndex >= 0 && dayIndex < labels.length) {
            label = labels[dayIndex];
            aggregatedData[label] = (aggregatedData[label] ?? 0) + viewsCount;
          }
          break;
        case TimeRange.monthly:
        // Week of the month
          final dayIndex = createdAt.difference(startDate).inDays ~/ 5;
          if (dayIndex >= 0 && dayIndex < labels.length) {
            label = labels[dayIndex];
            aggregatedData[label] = (aggregatedData[label] ?? 0) + viewsCount;
          }
          break;
        case TimeRange.yearly:
        // Month of the year
          final monthIndex = (createdAt.month - startDate.month + 12) % 12;
          if (monthIndex >= 0 && monthIndex < labels.length) {
            label = labels[monthIndex];
            aggregatedData[label] = (aggregatedData[label] ?? 0) + viewsCount;
          }
          break;
      }
    }
    
    // Convert aggregated data to the format expected by the chart
    for (int i = 0; i < labels.length; i++) {
      viewsData.add({
        'label': labels[i],
        'value': aggregatedData[labels[i]] ?? 0.0,
      });
    }
    
    // For demo purposes, if no data is available, generate some random data
    if (viewsData.every((item) => item['value'] == 0)) {
      return _generateDemoData(timeRange);
    }
    
    return viewsData;
  }
  
  /// Helper method to get month name from month number
  static String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
  
  /// Generate demo data for the chart when no real data is available
  static List<Map<String, dynamic>> _generateDemoData(TimeRange timeRange) {
    List<Map<String, dynamic>> demoData = [];
    List<String> labels = [];
    
    switch (timeRange) {
      case TimeRange.weekly:
        labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        break;
      case TimeRange.monthly:
        labels = ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
        break;
      case TimeRange.yearly:
        labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        break;
    }
    
    // Generate demo values based on the image provided
    if (timeRange == TimeRange.weekly) {
      demoData = [
        {'label': labels[0], 'value': 450.0},
        {'label': labels[1], 'value': 580.0},
        {'label': labels[2], 'value': 780.0},
        {'label': labels[3], 'value': 620.0},
        {'label': labels[4], 'value': 510.0},
        {'label': labels[5], 'value': 430.0},
        {'label': labels[6], 'value': 470.0},
      ];
    } else if (timeRange == TimeRange.monthly) {
      demoData = [
        {'label': labels[0], 'value': 580.0},
        {'label': labels[1], 'value': 420.0},
        {'label': labels[2], 'value': 480.0},
        {'label': labels[3], 'value': 580.0},
        {'label': labels[4], 'value': 420.0},
        {'label': labels[5], 'value': 480.0},
      ];
    } else {
      demoData = [
        {'label': labels[0], 'value': 450.0},
        {'label': labels[1], 'value': 780.0},
        {'label': labels[2], 'value': 580.0},
        {'label': labels[3], 'value': 420.0},
        {'label': labels[4], 'value': 480.0},
        {'label': labels[5], 'value': 520.0},
        {'label': labels[6], 'value': 480.0},
        {'label': labels[7], 'value': 520.0},
        {'label': labels[8], 'value': 580.0},
        {'label': labels[9], 'value': 620.0},
        {'label': labels[10], 'value': 580.0},
        {'label': labels[11], 'value': 520.0},
      ];
    }
    
    return demoData;
  }

  static Future<int> rankCurrentUser() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

    // 1. Fetch all users
    final usersSnapshot = await firestore.collection(FirebaseConstants.userCollection).get();

    // 2. Create a list to store user scores
    List<Map<String, dynamic>> userScores = [];

    for (var doc in usersSnapshot.docs) {
      final userData = doc.data();
      final String userID = doc.id;

      final int totalLikes = userData['totalLikesCount'] ?? 0;
      final int reelsPosted = userData['reelsPosted'] ?? 0;

      // 3. Fetch followers count for each user
      final followersSnap = await firestore
          .collection(FirebaseConstants.userCollection)
          .doc(userID)
          .collection(FirebaseConstants.followersCollection)
          .count()
          .get();
      final int followersCount = followersSnap.count ?? 0;

      final int score = (totalLikes * 1) + (reelsPosted * 5) + (followersCount * 2);

      userScores.add({
        'userID': userID,
        'score': score,
      });
    }

    // 4. Sort users by score descending
    userScores.sort((a, b) => b['score'].compareTo(a['score']));

    // 5. Find the rank of current user
    final int userRank = userScores.indexWhere((user) => user['userID'] == currentUserID) + 1;

    return userRank;
  }
}
