import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../res/app_colors.dart';
import '../../res/app_icons.dart';
import '../../res/app_textstyles.dart';
import '../../widgets/primary_btn.dart';

class CameraEmotionDetection extends StatefulWidget{
  final bool isSelected;

  const CameraEmotionDetection({super.key, required this.isSelected});

  @override
  State<CameraEmotionDetection> createState() => _CameraEmotionDetectionState();
}

class _CameraEmotionDetectionState extends State<CameraEmotionDetection> {
  CameraController? _cameraController;
  final _faceDetector = FaceDetector(options: FaceDetectorOptions(
    enableClassification: true,
    enableLandmarks: true,
    enableTracking: true,
    performanceMode: FaceDetectorMode.accurate
  ));

  bool _isDetecting = false;
  List<Face> _faces = [];
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  Future<void>? _initializeControllerFuture;
  @override
  void initState() {
    _initRequestPermission();
    _initCameras();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.lightPurple,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      width: double.infinity,
      child: Column(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Camera", style: AppTextStyles.buttonTextStyle.copyWith(fontWeight: FontWeight.w900, color: Colors.white),),
                    Text("Let’s capture your vibe! 😎", style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400, color: Colors.white),),
                  ],
                ),
              ),
              if(!widget.isSelected)
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.done, color: Colors.black, size: 20,),
                )
            ],
          ),
          const SizedBox(height: 20,),
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.black,
              child: FutureBuilder(future: _initializeControllerFuture, builder: (_, snapshot){
                if(snapshot.connectionState == ConnectionState.done && _cameraController != null && _cameraController!.value.isInitialized){
                  return Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(1000),
                          child: CameraPreview(_cameraController!)),
                      CustomPaint(
                        painter: FaceDetectionPainter(
                          faces: _faces,
                          imageSize : Size(_cameraController!.value.previewSize!.width, _cameraController!.value.previewSize!.height),
                          lensDirection: _cameraController!.description.lensDirection
                        ),
                      ),

                      Positioned(
                          bottom: 20,
                          right: 0,
                          left: 0,
                          child:  Center(child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20)
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Text('${_faces.length} Faces detected', style: AppTextStyles.bodyTextStyle,),
                          ),)),

                    ],
                  );
                }else if(snapshot.connectionState == ConnectionState.waiting){
                  return  Center(child: Text("Camera Goes here", style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400, color: Colors.white),),);
                }
                return SizedBox();
              })
              //
            ),
          ),
          const SizedBox(height: 12,),
          PrimaryBtn(btnText: "Done", icon: AppIcons.icArrowNext, onTap: (){})
        ],
      ),
    );
  }

  Future<void> _initCameras()async{
    _cameras = await availableCameras();
    _selectedCameraIndex = _cameras.indexWhere((camera)=> camera.lensDirection == CameraLensDirection.front);

    if(_selectedCameraIndex == -1){
      _selectedCameraIndex = 0;
    }

    _initializeCamera(_cameras[_selectedCameraIndex]);
  }

  void _startFaceDetection() {
    if(_cameraController == null || !_cameraController!.value.isInitialized){
      return;
    }

    _cameraController!.startImageStream((CameraImage image) async {
      if(_isDetecting) return;

      _isDetecting = true;
      final inputImage = _convertCameraImageToInputImage(image);
      if(inputImage == null){
        _isDetecting = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);
      if(mounted){
        _faces = faces;
        setState(() {});
      }
      try{

      }catch(e){
        debugPrint("Error while face detecting: ${e.toString()}");
      }finally{
        _isDetecting = false;
      }
    });
  }

  Future<void> _toggleCamera() async {
    if(_cameras.isEmpty || _cameras.length < 2){
      debugPrint("Cannot toggle the camera");
      return;
    }

    if(_cameraController != null && _cameraController!.value.isStreamingImages){
      await _cameraController!.stopImageStream();
    }

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _faces = [];
    setState(() {});

     _initializeCamera(_cameras[_selectedCameraIndex]);
  }

  void _initializeCamera(CameraDescription camera) {
    _cameraController = CameraController(camera, ResolutionPreset.ultraHigh,
        enableAudio: false, imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420);

    _initializeControllerFuture = _cameraController!.initialize().then((val){
      if(!mounted) return;
      setState(() {
        _startFaceDetection();
      });
    }).catchError((error){
      debugPrint("Error found while initializing the camera: ${error.toString()}");
    });
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    try{
      final format = Platform.isIOS ? InputImageFormat.bgra8888 : InputImageFormat.nv21;
      final size = Size(image.width.toDouble(), image.height.toDouble());
      final rotation = InputImageRotation.values.firstWhere((value)=> value.rawValue == _cameraController!.description.sensorOrientation, orElse: ()=> InputImageRotation.rotation0deg);
      final bytesPerRow =  image.planes[0].bytesPerRow;

      final inputImageMetaData = InputImageMetadata(
          size: size,
          rotation: rotation,
          format: format,
          bytesPerRow: bytesPerRow);
      final bytes = _concatePlanes(image.planes);
      return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetaData);
    }catch(e){
      debugPrint("Error while converting image to input image: ${e.toString()}");
    }

    return null;
  }

  _concatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();

    for (var plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }

    return allBytes.done().buffer.asUint8List();
  }

  void _initRequestPermission() async{
    await Permission.camera.request();
  }
}

class FaceDetectionPainter extends CustomPainter{
  final List<Face> _faces;
  final Size _imageSize;
  final CameraLensDirection _lensDirection;

  FaceDetectionPainter({required List<Face> faces, required Size imageSize, required CameraLensDirection lensDirection}) : _faces = faces, _imageSize = imageSize, _lensDirection = lensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / _imageSize.width;
    final double scaleY = size.height / _imageSize.height;

    final facePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      .. color = AppColors.purpleColor;

    final landMarkPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0
      .. color = Colors.blue;

    final textBackgroundPaint = Paint()
      ..style = PaintingStyle.fill
      .. color = Colors.black54;

    for(int i = 0; i<_faces.length; i++){
      Face face = _faces[i];

      double leftOffset = face.boundingBox.left;
      if(_lensDirection == CameraLensDirection.front){
        leftOffset = _imageSize.width - face.boundingBox.right;
      }

      final double left =  scaleX;
      final double top = scaleY;
      final double right = (leftOffset + face.boundingBox.width*0.8) * scaleX;
      final double bottom = (face.boundingBox.top + face.boundingBox.height*0.6) * scaleY;

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), facePaint);

      void drawLandMark(FaceLandmarkType type){
        if(face.landmarks[type] != null){
          final point = face.landmarks[type]!.position;
          double pointX = point.x.toDouble();
          if(_lensDirection == CameraLensDirection.front){
            pointX = _imageSize.width - pointX;
          }

          canvas.drawCircle(Offset(pointX * scaleX, point.y*scaleY), 4.0, landMarkPaint);
        }
      }

      drawLandMark(FaceLandmarkType.leftEye);
      drawLandMark(FaceLandmarkType.rightEye);
      drawLandMark(FaceLandmarkType.noseBase);
      drawLandMark(FaceLandmarkType.leftMouth);
      drawLandMark(FaceLandmarkType.rightMouth);
      drawLandMark(FaceLandmarkType.bottomMouth);

      String mood = 'Neutral';

      debugPrint("Smiling probability: ${face.smilingProbability}");
      final probability = face.smilingProbability ?? 0;

      switch(probability){
        case > 0.8:
          mood = 'Laughing 😂';
          break;

        case > 0.5:
          mood = 'Smiling 😊';
          break;

        case < 0.1:
          mood = 'Serious 🙂';
          break;

        default:
          mood = 'Neutral';
      }

      final textSpan = TextSpan(
          text: 'Face $i\n$mood',
        style: AppTextStyles.buttonTextStyle.copyWith(fontFamily: AppConstants.appFontFamily, color: AppColors.purpleColor)
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center
      );

      textPainter.layout();

      final textRect = Rect.fromLTWH(left, top - textPainter.height -8 , textPainter.width + 16, textPainter.height + 8);

      canvas.drawRRect(RRect.fromRectAndRadius(textRect, Radius.circular(10)), textBackgroundPaint);
      textPainter.paint(canvas, Offset(left + 8, top - textPainter.height - 4));
    }
  }

  @override
  bool shouldRepaint(FaceDetectionPainter oldDelegate) {
    return oldDelegate._faces == _faces;
  }
}
