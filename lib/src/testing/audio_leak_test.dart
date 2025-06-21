import 'package:flutter/material.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/services/scroll_detector.dart';
import 'package:funli_app/src/services/video_audio_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:funli_app/src/features/reels_page/reels_optimized_player_widget.dart';

/// A test page to verify audio leakage fixes
/// This page creates multiple video players and allows testing fast scrolling
class AudioLeakTestPage extends StatefulWidget {
  const AudioLeakTestPage({super.key});

  @override
  State<AudioLeakTestPage> createState() => _AudioLeakTestPageState();
}

class _AudioLeakTestPageState extends State<AudioLeakTestPage> {
  // Test videos - replace with actual test videos
  final List<String> _testVideos = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
  ];

  final List<VideoPlayerController> _controllers = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    
    // Attach scroll detector to the scroll controller
    ScrollDetector().attachToController(_scrollController);
  }

  Future<void> _initializeControllers() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize controllers for all test videos
    for (int i = 0; i < _testVideos.length; i++) {
      final controller = VideoPlayerController.network(_testVideos[i]);
      
      // Register with VideoAudioManager
      VideoAudioManager().registerController('test_video_$i', controller);
      
      await controller.initialize();
      _controllers.add(controller);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _controllers) {
      VideoAudioManager().unregisterController('test_video_${_controllers.indexOf(controller)}');
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Leak Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_off),
            onPressed: () {
              // Mute all videos
              VideoAudioManager().pauseAll();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeControllers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Scroll quickly to test audio leakage prevention',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _controllers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Test Video ${index + 1}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            AspectRatio(
                              aspectRatio: _controllers[index].value.aspectRatio,
                              child: ReelsOptimizedPlayerWidget(
                                controller: _controllers[index],
                                reelID: 'test_video_$index',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Play this video with audio
                                      VideoAudioManager().playVideo('test_video_$index');
                                    },
                                    child: const Text('Play'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Pause this video
                                      _controllers[index].pause();
                                    },
                                    child: const Text('Pause'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Simulate fast scroll
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
            );
          }
        },
        child: const Icon(Icons.fast_forward),
      ),
    );
  }
}

/// A route to launch the test page
class AudioLeakTestRoute {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => const AudioLeakTestPage(),
    );
  }
}
