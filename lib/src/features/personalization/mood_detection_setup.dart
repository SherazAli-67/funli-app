import 'package:flutter/material.dart';


class MoodDetectionSetup extends StatefulWidget {
  const MoodDetectionSetup({super.key});

  @override
  _MoodDetectionSetupState createState() => _MoodDetectionSetupState();
}

class _MoodDetectionSetupState extends State<MoodDetectionSetup> with SingleTickerProviderStateMixin {
  CardState _cardState = CardState.camera;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeState(CardState newState) {
    setState(() {
      _cardState = newState;
      _controller.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Detection Setup'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nice Job! Let\'s personalize FUN!! for you',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Stack for overlapping cards
              SizedBox(
                height: 700, // Adjust based on your content
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Text Card (bottom)
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      top: _cardState == CardState.text ? 240 : 360,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _changeState(CardState.text),
                        child: _buildTextCard(_cardState == CardState.text),
                      ),
                    ),

                    // Voice Card (middle)
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      top: _cardState != CardState.camera ? 120 : 240,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _changeState(CardState.voice),
                        child: _buildVoiceCard(_cardState == CardState.voice),
                      ),
                    ),

                    // Camera Card (always on top)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _changeState(CardState.camera),
                        child: _buildCameraCard(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraCard() {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Camera',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Let\'s capture your vibe!'),
            SizedBox(height: 20),
            Container(
              height: 200,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: Text('Camera Goes here'),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Done',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceCard(bool isExpanded) {
    return Card(
      elevation: isExpanded ? 8 : 4,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Voice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Speak your mood and let Fun!!'),
            if (isExpanded) ...[
              SizedBox(height: 20),
              Container(
                height: 100,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic, size: 40),
                    SizedBox(height: 10),
                    Text('Tap & Hold the button to speak your feelings'),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Done',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextCard(bool isExpanded) {
    return Card(
      elevation: isExpanded ? 8 : 4,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Texts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Type how you\'re feeling today.'),
            if (isExpanded) ...[
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your mood here...',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Done',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum CardState { camera, voice, text }