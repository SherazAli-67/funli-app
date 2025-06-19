import 'dart:async';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/features/main_menu/video_feed_view/bloc_cubit/video_feed_cubit.dart';
import 'package:funli_app/src/providers/record_upload_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:funli_app/src/widgets/mood_selecting_scroll_wheel_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class CreateUploadFeelPage extends StatefulWidget {
  const CreateUploadFeelPage({super.key});

  @override
  CreateUploadFeelPageState createState() => CreateUploadFeelPageState();
}

class CreateUploadFeelPageState extends State<CreateUploadFeelPage> with WidgetsBindingObserver {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  // bool _isRecording = false;
  bool _isCameraInitialized = false;

  bool _isRecording = false;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 4.0;
  int _selectedCameraIndex = 0;
  double _baseZoom = 1.0;

  late RecordUploadProvider _recordUploadProvider;

  Timer? _timer;
  int _elapsedSeconds = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera([int cameraIndex = 0]) async {
    _cameras = await availableCameras();
    _selectedCameraIndex = cameraIndex;

    _controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _controller.initialize();
    _minZoom = await _controller.getMinZoomLevel();
    _maxZoom = await _controller.getMaxZoomLevel();

    setState(() {
      _isCameraInitialized = true;
      _currentZoom = 1.0;
    });
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ( !_controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(_selectedCameraIndex);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _recordUploadProvider = Provider.of<RecordUploadProvider>(context);

    double scale =1;
   if(_isCameraInitialized){
      scale = 1 / (_controller.value.aspectRatio * size.aspectRatio);
   }
    return Scaffold(
      body: _isCameraInitialized
          ? GestureDetector(
        onDoubleTap: _toggleCamera,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
            child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
            // Image.network(AppIcons.icDummyImgUrl,fit: BoxFit.cover, height: size.height,),
                      Transform.scale(
                        scale: scale,
                        alignment: Alignment.topCenter,
                        child: CameraPreview(_controller),
                      ),
            Positioned(
              bottom: 0,
              left: 30,
              right: 30,
              child: Consumer<RecordUploadProvider>(
                builder: (ctx, provider, _) {
                  return Column(
                    spacing: 16,
                    children: [
                      Row(
                        spacing: 12,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildVideoDurationWidget(duration: '1m', provider: provider),
                          _buildVideoDurationWidget(duration: '30s',provider: provider),
                          _buildVideoDurationWidget(duration: '15s  ',provider: provider),

                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(onPressed: ()async{
                            _toggleCamera();
                          }, icon: Icon(Icons.change_circle_rounded, color: Colors.white, size: 35,)),
                          if(_isRecording)
                            GestureDetector(
                              onTap: () {
                                _stopRecording(context: context);
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: Duration(seconds: _getSelectedDurationInSeconds()),
                                      onEnd: () {
                                        if (_isRecording) {
                                          _stopRecording(context: context);
                                        }
                                      },
                                      builder: (context, value, child) {
                                        return CustomPaint(
                                          painter: CircularProgressPainter(progress: value),
                                          size: Size(80, 80),
                                        );
                                      },
                                    ),
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: AppGradients.primaryGradient,
                                      ),
                                    ),
                                    Positioned(
                                      top: -40,
                                      child: Text(
                                        _recordingDurationText(),
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          if(!_isRecording)
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppGradients.primaryGradient
                                ),
                                margin: EdgeInsets.all(5),
                                padding: EdgeInsets.all(10),

                                child: IconButton(onPressed: (){
                                  _startRecording();
                                },
                                    icon: SvgPicture.asset( AppIcons.icRecordVideo,
                                      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),)),
                              ),
                            ),
                          IconButton(onPressed: ()async{
                            String? selectedVideoPath = await _onSelectVideoFromGalleryTap();
                            if(selectedVideoPath != null){
                              _navigateToEditFeelPage(context: context, path: selectedVideoPath);
                            }
                          }, icon: SvgPicture.asset(AppIcons.icUpload))
                        ],
                      )
                    ],
                  );
                }
              ),
            ),
                      Positioned(
                        top: 65 ,
                        left: 30,
                        right: 30,
                        child: Consumer<RecordUploadProvider>(
                            builder: (ctx, provider, _) {
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  spacing: 16,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            // Reset shouldPauseVideo to false when returning to video feed
                                            // Ensure we trigger preloading when returning to feed
                                            final cubit = context.read<VideoFeedCubit>();
                                            cubit.setShouldPauseVideo(false);
                                            // Trigger preloading before navigation
                                            cubit.preloadNextVideos();
                                            context.pop();
                                          }, 
                                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white,)
                                        ),
                                        Text("Record a video", style: AppTextStyles.headingTextStyle3.copyWith(color: Colors.white),),
                                        const SizedBox(width: 40,),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        final result = await showModalBottomSheet(
                                            isDismissible: false,
                                            context: context, builder: (_){
                                          return MoodSelectingScrollWheelWidget(selectedMood: provider.currentMood,);
                                        });

                                        if(result != null){
                                          provider.setCurrentMood(result);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                                        decoration: BoxDecoration(
                                            color: AppColors.yellowAccentColor,
                                            borderRadius: BorderRadius.circular(SpacingConstants.btnBorderRadius)
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 10,
                                          children: [
                                            Text("You seem ${AppData.getEmojiByMood(provider.currentMood)} ${provider.currentMood}", style: AppTextStyles.buttonTextStyle,),
                                            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black,)
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                        ),
                      ),
                    ],
                  ),
          )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildVideoDurationWidget({required String duration, required RecordUploadProvider provider}) {
    bool isSelected = provider.videoRecordingDuration == duration;
    return GestureDetector(
      onTap: ()=> provider.setRecordingDuration(duration),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.lightDarkBgColor,
            borderRadius: BorderRadius.circular(SpacingConstants.btnBorderRadius)
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Text(duration, style: AppTextStyles.smallTextStyle.copyWith(
            fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.greyTextColor),),
      ),
    );
  }

  int _getSelectedDurationInSeconds() {
    final durationStr = _recordUploadProvider.videoRecordingDuration;
    if (durationStr.contains("1m")) return 60;
    if (durationStr.contains("30s")) return 30;
    return 15;
  }
  String _recordingDurationText() {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  Future<String?> _onSelectVideoFromGalleryTap() async{
    FilePicker filePicker = FilePicker.platform;
    FilePickerResult? result = await filePicker.pickFiles(
        type: FileType.video,
        allowMultiple: false
    );

    if(result != null){
      PlatformFile file = result.files.first;

      return file.path;
    }

    return null;
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    int newIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _controller.dispose();
    await _initCamera(newIndex);
  }

  Future<void> _startRecording() async {
    if (!_controller.value.isInitialized || _isRecording) return;

    final directory = await getTemporaryDirectory();
    join(directory.path, '${DateTime.now().millisecondsSinceEpoch}.mp4');

    await _controller.startVideoRecording();
    setState(() {
      _isRecording = true;
      _elapsedSeconds = 0;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });


    debugPrint("Recording started");
  }

  Future<void> _stopRecording({required BuildContext context}) async {
    if (!_controller.value.isRecordingVideo) return;

    final file = await _controller.stopVideoRecording();
    setState(()=> _isRecording = false);

    _recordUploadProvider.setRecordingPath(file.path);

    _timer?.cancel();
    _timer = null;
    _navigateToEditFeelPage(context: context, path: file.path);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = _currentZoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) async {
    if ( !_controller.value.isInitialized) return;

    double newZoom = (_baseZoom * details.scale).clamp(_minZoom, _maxZoom);
    await _controller.setZoomLevel(newZoom);
    setState(()=>  _currentZoom = newZoom);
  }

  void _navigateToEditFeelPage({required BuildContext context, required String path}) {
    context.pushReplacement(RouterEnum.editUploadedReelView.routeName, extra: {
      'videoPath' : path
    });
  }

}

class CircularProgressPainter extends CustomPainter {
  final double progress;

  CircularProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 6.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final gradient = SweepGradient(
      colors: [
        Colors.yellow,
        Colors.orange,
        Colors.red,
        Colors.purple,
        Colors.blue,
        Colors.green,
        Colors.yellow,
      ],
      stops: [0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 1.0],
    );

    final foregroundPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14 / 2,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
