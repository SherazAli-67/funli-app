import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/providers/record_upload_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:provider/provider.dart';

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
    // final scale = 1 / (_controller.value.aspectRatio * size.aspectRatio);

    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
        children: [
          Image.network(AppIcons.icDummyImgUrl,fit: BoxFit.cover, height: size.height,),
          /*Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: Image.network(AppIcons.icDummyImgUrl,fit: BoxFit.fitHeight,)
            
            // CameraPreview(_controller),
          ),*/
          Positioned(
            bottom: 45,
            left: 30,
            right: 30,
            child: Consumer<RecordUploadProvider>(
              builder: (_, provider, _) {
                return Column(
                  spacing: 16,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        _buildVideoDurationWidget(duration: '1m', provider: provider),
                        _buildVideoDurationWidget(duration: '30s',provider: provider),
                        _buildVideoDurationWidget(duration: '15s  ',provider: provider),
                
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(
                          width: 40,
                        ),
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

                            child: IconButton(onPressed: (){}, icon: SvgPicture.asset(AppIcons.icRecordVideo)),
                          ),
                        ),
                        IconButton(onPressed: (){}, icon: SvgPicture.asset(AppIcons.icUpload))
                      ],
                    )
                  ],
                );
              }
            ),
          ),
          Positioned(
            top: 45,
            left: 30,
            right: 30,
            child: Consumer<RecordUploadProvider>(
                builder: (_, provider, _) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      spacing: 16,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppBackButton(color: Colors.white,),
                            Text("Record a video", style: AppTextStyles.headingTextStyle3.copyWith(color: Colors.white),),
                            const SizedBox(width: 40,),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                          decoration: BoxDecoration(
                            color: AppColors.yellowAccentColor,
                            borderRadius: BorderRadius.circular(SpacingConstants.btnBorderRadius)
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              Text("You seem 😄 Happy", style: AppTextStyles.buttonTextStyle,),
                              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black,)
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
            ),
          ),

        ],
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
}