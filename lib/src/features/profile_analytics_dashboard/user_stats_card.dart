import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStatsCard extends StatefulWidget {
  const UserStatsCard({super.key});

  @override
  State<UserStatsCard> createState() => _UserStatsCardState();
}

class _UserStatsCardState extends State<UserStatsCard> {
  int totalFeels = 0;
  int totalViews = 0;
  int totalLoves = 0;
  int totalFollowers = 0;

  double feelsGrowth = 0.0;
  double viewsGrowth = 0.0;
  double lovesGrowth = 0.0;
  double followersGrowth = 0.0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    final userReelsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('reels');

    final userReelsSnapshot = await userReelsRef.get();
    final mappedList = userReelsSnapshot.docs.map((doc) => doc.data()).toList();

    int feels = mappedList.length;
    int views = 0;
    int loves = 0;

    for (var userReel in mappedList) {
      views += int.parse((userReel['viewsCount'] ?? 0).toString());
      loves += int.parse((userReel['likesCount']?? 0).toString());
    }

    final followersSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('followers').count()
        .get();

    final followersCount = followersSnap.count;

    // Here you would calculate growth percentages based on previous data
    setState(() {
      totalFeels = feels;
      totalViews = views;
      totalLoves = loves;
      totalFollowers = followersCount ?? 0;

      // Dummy growth values
      feelsGrowth = 2.5;
      viewsGrowth = 0.5;
      lovesGrowth = -2.5;
      followersGrowth = -5.0;

      isLoading = false;
    });
  }

  Widget _buildStatCard(String label, int count, double changePercent) {
    final isPositive = changePercent >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                '${changePercent.abs()}%',
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3/2.5,
      children: [
        _buildStatCard('Total Feels', totalFeels, feelsGrowth),
        _buildStatCard('Total Views', totalViews, viewsGrowth),
        _buildStatCard('Total Loves', totalLoves, lovesGrowth),
        _buildStatCard('Total Followers', totalFollowers, followersGrowth),

      ],
    );
  }
}