import 'dart:math';
import 'package:flutter/material.dart';

class MoodWheelSheet extends StatefulWidget {
  @override
  _MoodWheelSheetState createState() => _MoodWheelSheetState();
}

class _MoodWheelSheetState extends State<MoodWheelSheet> {
  List<String> moods = ["😢", "😐", "😄", "😒", "🤣"];
  int currentIndex = 2;

  void rotateLeft() {
    setState(() {
      currentIndex = (currentIndex + 1) % moods.length;
    });
  }

  void rotateRight() {
    setState(() {
      currentIndex = (currentIndex - 1 + moods.length) % moods.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    double radius = 90;
    return Container(
      padding: EdgeInsets.only(top: 24, bottom: 40),
      height: 400, // Important: set fixed height
      child: Column(
        children: [
          Text(
            "Change your mood!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),

          // Fixed height + Stack
          SizedBox(
            width: double.infinity,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(moods.length, (i) {
                double angle = 2 * pi * (i - currentIndex + moods.length) % moods.length / moods.length;
                double x = radius * cos(angle);
                double y = radius * sin(angle);

                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 + x - 20,
                  top: 70 + y,
                  child: Opacity(
                    opacity: i == currentIndex ? 1.0 : 0.5,
                    child: Text(
                      moods[i],
                      style: TextStyle(fontSize: i == currentIndex ? 44 : 28),
                    ),
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 24),
          Text(getMoodName(moods[currentIndex]), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Text("(Current)", style: TextStyle(color: Colors.grey)),

          Spacer(),

          // Colorful button with tap detection
          GestureDetector(
            onTapDown: (details) {
              final box = context.findRenderObject() as RenderBox;
              final localPos = box.globalToLocal(details.globalPosition);
              final width = box.size.width;

              if (localPos.dx < width / 2) {
                rotateRight(); // Tap on left side
              } else {
                rotateLeft(); // Tap on right side
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
          )
        ],
      ),
    );
  }

  String getMoodName(String emoji) {
    switch (emoji) {
      case "😄":
        return "Happy";
      case "😢":
        return "Sad";
      case "😐":
        return "Neutral";
      case "😒":
        return "Annoyed";
      case "🤣":
        return "Laughing";
      default:
        return "Mood";
    }
  }
}
