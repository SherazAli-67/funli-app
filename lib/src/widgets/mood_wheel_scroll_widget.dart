import 'dart:math';
import 'package:flutter/material.dart';

class MoodWheelScreen extends StatefulWidget {
  @override
  _MoodWheelScreenState createState() => _MoodWheelScreenState();
}

class _MoodWheelScreenState extends State<MoodWheelScreen> {
  final List<Map<String, String>> moods = [
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😥', 'label': 'Crying'},
    {'emoji': '😄', 'label': 'Happy'},
    {'emoji': '😒', 'label': 'Annoyed'},
    {'emoji': '🤣', 'label': 'Laughing'},
    {'emoji': '😡', 'label': 'Angry'},
  ];

  late PageController _controller;
  int currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: currentIndex,
      viewportFraction: 0.3,
    );

    _controller.addListener(() {
      final newIndex = _controller.page!.round();
      if (newIndex != currentIndex) {
        setState(() {
          currentIndex = newIndex;
        });
      }
    });
  }

  void scrollLeft() {
    if (currentIndex < moods.length - 1) {
      _controller.animateToPage(currentIndex + 1,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void scrollRight() {
    if (currentIndex > 0) {
      _controller.animateToPage(currentIndex - 1,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Text("Change your mood!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          SizedBox(
            height: 160,
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: _controller,
              itemCount: moods.length,
              itemBuilder: (_, index) {
                final offset = (index - currentIndex).toDouble();
                final scale = max(0.8, 1.2 - offset.abs() * 0.3);
                final verticalOffset = offset.abs() * 20;

                return Transform.translate(
                  offset: Offset(0, verticalOffset),
                  child: Opacity(
                    opacity: offset.abs() > 2 ? 0.0 : 1.0,
                    child: Center(
                      child: Text(
                        moods[index]['emoji']!,
                        style: TextStyle(fontSize: 60 * scale),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          Text(
            moods[currentIndex]['label']!,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text("(Current)", style: TextStyle(color: Colors.grey)),
          const Spacer(),

          GestureDetector(
            onTapDown: (details) {
              final width = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < width / 2) {
                scrollRight(); // Left tap
              } else {
                scrollLeft(); // Right tap
              }
            },
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(colors: [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.purple,
                  Colors.red,
                ]),
              ),
              child: Center(
                child: Icon(Icons.compare_arrows, color: Colors.white, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
