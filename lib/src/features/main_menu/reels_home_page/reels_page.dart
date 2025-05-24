// screens/reels_screen.dart
import 'package:flutter/material.dart';
import 'package:funli_app/src/features/main_menu/reels_home_page/reels_item_widget.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:whitecodel_reels/whitecodel_reels.dart';

import '../../../providers/reels_provider.dart';
class ReelsPage extends StatefulWidget {

  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final provider = Provider.of<ReelProvider>(context, listen: false);
      provider.fetchReels();

      _scrollController = ScrollController()
        ..addListener(() {
          if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
            provider.fetchReels();
          }
        });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReelProvider>(
      builder: (context, provider, _) {
        final reels = provider.reels;

        if (provider.isLoading && reels.isEmpty) {
          return LoadingWidget();
        }

        if (reels.isEmpty) {
          return const Center(child: Text("No reels available."));
        }

        return Center(child: Text("Reels found: ${reels.length}"),);
       /* return ListView.builder(
          controller: _scrollController,
          itemCount: reels.length + (provider.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == reels.length) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: LoadingWidget(),
              ));
            }

            final reel = reels[index];
            return ReelItemWidget(reel: reel);
          },
        );*/
      },
    );
  }
}