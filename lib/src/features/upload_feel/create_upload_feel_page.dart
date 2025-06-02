import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/upload_feel/edit_uploaded_feel.dart';
import 'package:funli_app/src/providers/record_upload_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
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

                              child: IconButton(onPressed: (){
                                if(_isRecording){
                                  _stopRecording(context: context);
                                }else{
                                  _startRecording();
                                }
                              },
                                  icon: SvgPicture.asset(_isRecording
                                      ? AppIcons.icStopRecording
                                      : AppIcons.icRecordVideo,
                                    colorFilter: ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),)),
                            ),
                          ),
                          IconButton(onPressed: ()async{
                            String? selectedVideoPath = await _onSelectVideoFromGalleryTap();
                            if(selectedVideoPath != null){
                              Navigator.of(context).push(MaterialPageRoute(builder: (_)=> EditUploadedFeelPage(videoPath: selectedVideoPath)));
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
    setState(()=>  _isRecording = true);
    debugPrint("Recording started");
  }

  Future<void> _stopRecording({required BuildContext context}) async {
    if (!_controller.value.isRecordingVideo) return;

    final file = await _controller.stopVideoRecording();
    setState(()=> _isRecording = false);

    _recordUploadProvider.setRecordingPath(file.path);
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> EditUploadedFeelPage(videoPath: file.path,)));
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

}