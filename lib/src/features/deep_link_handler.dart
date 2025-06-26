import 'package:flutter/material.dart';
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
    debugPrint("ReelID found: ${widget.reelID}");
    return Scaffold(
      body: SafeArea(child: Center(child: LoadingWidget(),)),
    );
  }

  void _initReel() async {
    try {
      // Fetch the reel by ID
      final reel = await ReelsService.getReelByID(widget.reelID);

      if (reel != null) {
        debugPrint("Navigating to reels page: ${reel.caption}");
        // Ensure navigation happens after the widget is fully mounted
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Navigate to the UpdatedReelsPage with the fetched reel
          context.push(
            RouterEnum.updatedReelsView.routeName,
            extra: {
              'initialReels': [reel],
              'selectedIndex': 0,
              'lastDocument': null,
              'comingFrom': 'deeplink',
            },
          );
        });
      } else {
        print('Reel not found: ${widget.reelID}');
      }
    } catch (e) {
      print('Error navigating to reel: $e');
    }
  }
}
