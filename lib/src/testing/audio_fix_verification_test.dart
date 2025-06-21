import 'package:flutter/material.dart';
import 'package:funli_app/src/services/video_audio_manager.dart';
import 'package:video_player/video_player.dart';

/// Test page to verify audio fixes are working correctly
class AudioFixVerificationTest extends StatefulWidget {
  const AudioFixVerificationTest({super.key});

  @override
  State<AudioFixVerificationTest> createState() => _AudioFixVerificationTestState();
}

class _AudioFixVerificationTestState extends State<AudioFixVerificationTest> {
  final _videoManager = VideoAudioManager();
  final List<String> _testVideos = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  ];
  
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, bool> _isInitialized = {};
  String? _currentlyPlaying;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  Future<void> _initializeControllers() async {
    for (int i = 0; i < _testVideos.length; i++) {
      final videoId = 'video_$i';
      final controller = VideoPlayerController.network(_testVideos[i]);
      
      _controllers[videoId] = controller;
      _isInitialized[videoId] = false;
      
      try {
        await controller.initialize();
        _videoManager.registerController(videoId, controller);
        
        setState(() {
          _isInitialized[videoId] = true;
        });
      } catch (e) {
        debugPrint('Error initializing video $videoId: $e');
      }
    }
  }
  
  @override
  void dispose() {
    for (final entry in _controllers.entries) {
      _videoManager.unregisterController(entry.key);
      entry.value.dispose();
    }
    super.dispose();
  }
  
  Widget _buildVideoCard(String videoId, int index) {
    final controller = _controllers[videoId];
    final isInitialized = _isInitialized[videoId] ?? false;
    final isPlaying = _currentlyPlaying == videoId;
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            height: 200,
            color: Colors.black,
            child: isInitialized && controller != null
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Video ${index + 1}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isInitialized
                          ? () async {
                              setState(() {
                                _currentlyPlaying = videoId;
                              });
                              await _videoManager.playVideo(videoId);
                            }
                          : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPlaying ? Colors.green : null,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: isInitialized && controller != null
                          ? () async {
                              await controller.pause();
                              await controller.setVolume(0.0);
                              if (_currentlyPlaying == videoId) {
                                setState(() {
                                  _currentlyPlaying = null;
                                });
                              }
                            }
                          : null,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (controller != null && isInitialized)
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(milliseconds: 100)),
                    builder: (context, snapshot) {
                      final position = controller.value.position;
                      final duration = controller.value.duration;
                      final isPlaying = controller.value.isPlaying;
                      final volume = controller.value.volume;
                      
                      return Column(
                        children: [
                          Text('Status: ${isPlaying ? "Playing" : "Paused"}'),
                          Text('Volume: ${(volume * 100).toInt()}%'),
                          Text('Position: ${_formatDuration(position)} / ${_formatDuration(duration)}'),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Fix Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _videoManager.debugPrintState();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Test Instructions'),
                  content: const Text(
                    '1. Click "Play" on any video\n'
                    '2. While it\'s playing, click "Play" on another video\n'
                    '3. The first video should automatically pause\n'
                    '4. Only one video should have audio at a time\n\n'
                    'Expected behavior:\n'
                    '- Only one video plays audio at a time\n'
                    '- Previous video pauses when new one plays\n'
                    '- Volume shows 100% for playing video, 0% for others',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _controllers.length,
        itemBuilder: (context, index) {
          final videoId = 'video_$index';
          return _buildVideoCard(videoId, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _videoManager.pauseAll();
          setState(() {
            _currentlyPlaying = null;
          });
        },
        child: const Icon(Icons.stop),
        tooltip: 'Pause All Videos',
      ),
    );
  }
}
