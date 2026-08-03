import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:go_router/go_router.dart';
import '../app_router/router_enum.dart';
import '../services/reels_service.dart';

class DeepLinkHandler extends StatefulWidget{
  const DeepLinkHandler({super.key, required this.reelID});
  final String reelID;

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  @override
  void initState() {
    _initReel();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: LoadingWidget(),)),
    );
  }

  void _initReel() async {
    try {
      // Fetch the reel by ID
      final reel = await ReelsService.getReelByID(widget.reelID);

      // Pause any playing videos in VideoFeedView before navigating
      try {
        // context.read<UpdatedFeedCubit>().setShouldPauseVideo(true);
        debugPrint("VideoFeed set playing true");
      } catch (e) {
        debugPrint('Error pausing videos: $e');
      }

      if (reel != null) {
        // Ensure navigation happens after the widget is fully mounted
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Navigate to the UpdatedReelsPage with the fetched reel
          context.pushReplacement(
            RouterEnum.updatedReelsView.routeName,
            extra: {
              'initialReels': [reel],
              'selectedIndex': 0,
              'lastDocument': null,
              'comingFrom': AppConstants.comingFromDeepLink,
            },
          );
        });
      } else {
        debugPrint('Reel not found: ${widget.reelID}');
        // Show a user-friendly error message if reel is not found
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reel not found. Please try another link.')),
          );
          // Navigate to a default page if needed
          context.go(RouterEnum.videoFeedView.routeName);
        });
      }
    } catch (e) {
      debugPrint('Error navigating to reel: $e');
      // Show error message to user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reel. Please try again later.')),
        );
        // Navigate to a default page
        context.go(RouterEnum.videoFeedView.routeName);
      });
    }
  }
}