import 'package:flutter/material.dart';
import 'package:funli_app/src/features/hashtagged_reels_page/hashtag_reels_widget.dart';
import 'package:funli_app/src/res/app_textstyles.dart';

class MoodReelsPage extends StatelessWidget{
  const MoodReelsPage({super.key, required String mood}): _mood = mood;
  final String _mood;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text("$_mood Feels", style: AppTextStyles.headingTextStyle3,),
        centerTitle: false,
      ),
      body: SafeArea(child: HashtagReelsGrid(tag: _mood, isComingFromMood: true,)),
    );
  }

}