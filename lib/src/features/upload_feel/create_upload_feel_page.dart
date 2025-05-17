import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class CreateUploadFeelPage extends StatefulWidget {
  const CreateUploadFeelPage({super.key});

  @override
  CreateUploadFeelPageState createState() => CreateUploadFeelPageState();
}

class CreateUploadFeelPageState extends State<CreateUploadFeelPage> with WidgetsBindingObserver {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _isRecording = false;
  bool _isCameraInitialized = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high, enableAudio: true);
    await _controller.initialize();
    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _startVideoRecording() async {
    if (!_controller.value.isInitialized || _isRecording) return;

    final directory = await getTemporaryDirectory();
    final videoPath = join(directory.path, '${DateTime.now().millisecondsSinceEpoch}.mp4');

    await _controller.startVideoRecording();
    setState(()=> _isRecording = true);
  }

  Future<void> _stopVideoRecording() async {
    if (!_controller.value.isRecordingVideo) return;

    final XFile file = await _controller.stopVideoRecording();
    setState(()=>  _isRecording = false);

    debugPrint("Video recorded to: ${file.path}");
    // TODO: Save or upload the video file as needed
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final scale = 1 / (_controller.value.aspectRatio * size.aspectRatio);

    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
        children: [
          Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: CameraPreview(_controller),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  children: [

                  ],
                )
              ],
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}