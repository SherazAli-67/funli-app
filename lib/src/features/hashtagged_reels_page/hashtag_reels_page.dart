import 'package:flutter/material.dart';

class HashtagReelsPage extends StatelessWidget{
  const HashtagReelsPage({super.key, required String hashtag}): _hashtag = hashtag;
  final String _hashtag;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Welcome to $_hashtag reels")
        ],
      )),
    );
  }

}