import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/features/main_menu/notifications/notification_item_widge.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/firebase_constants.dart';
import 'package:funli_app/src/widgets/gradient_icon.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import '../../../models/notification_model.dart';

class NotificationPage extends StatefulWidget{
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final List<NotificationModel> _notifications = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !_isLoading && _hasMore) {
        _fetchNotifications();
      }
    });
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FirebaseConstants.notificationsCollections)
        .orderBy("timestamp", descending: true)
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      final newNotifications = snapshot.docs.map((doc) =>
          NotificationModel.fromMap(doc.data() as Map<String, dynamic>)
      ).toList();
      _notifications.addAll(newNotifications);
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupNotificationsByDate(_notifications);

    return SafeArea(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_ios_new_rounded)),
              Text("Notifications", style: AppTextStyles.headingTextStyle3,),
              const SizedBox(width: 5,),
            ],
          ),
          Expanded(child: _isLoading
              ? LoadingWidget()
              : _notifications.isEmpty
              ? _buildEmptyNotesPage()
              : ListView(
              controller: _scrollController,
              children: grouped.entries.map((entry) {
                final sectionTitle = entry.key;
                final notifications = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        sectionTitle,
                        style: AppTextStyles.buttonTextStyle.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    ...notifications.map((notification) => NotificationItemWidget(notification: notification)),
                  ],
                );
              }).toList()
    )

          )
        ],
      ),
    );
  }


  Map<String, List<NotificationModel>> groupNotificationsByDate(List<NotificationModel> notifications) {
    final Map<String, List<NotificationModel>> grouped = {};

    for (var notification in notifications) {
      final label = getDateLabel(notification.timestamp.toDate());
      grouped.putIfAbsent(label, () => []).add(notification);
    }

    return grouped;
  }

  String getDateLabel(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (date == today) return "Today";
    if (date == today.subtract(Duration(days: 1))) return "Yesterday";
    if (now.difference(date).inDays <= 7) return "This Week";
    return "Earlier";
  }

  _buildEmptyNotesPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [
        GradientIcon(icon: Icons.notifications_none_rounded, size: 55, gradient: AppGradients.primaryGradient),
        Text("No Notifications Right Now!", style: AppTextStyles.tileTitleTextStyle, textAlign: TextAlign.center,),
        Text("You're up to date", style: AppTextStyles.bodyTextStyle,)
      ],
    );
  }
}