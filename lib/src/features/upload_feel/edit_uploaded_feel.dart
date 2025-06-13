import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:funli_app/src/features/upload_feel/publish_reel_page.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../providers/record_upload_provider.dart';
import '../../res/app_textstyles.dart';
import '../../widgets/app_back_button.dart';

class EditUploadedFeelPage extends StatefulWidget{
  const EditUploadedFeelPage({super.key, required this.videoPath});
  final String videoPath;
  @override
  State<EditUploadedFeelPage> createState() => _EditUploadedFeelPageState();
}

class _EditUploadedFeelPageState extends State<EditUploadedFeelPage> {

  bool _showTrimmer = false;
  bool _showPlaybackSpeed = false;
  bool _isMuted = false;

  late RecordUploadProvider _provider;
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;

  _saveVideo() {
    _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (outputPath) {
        final provider = Provider.of<RecordUploadProvider>(context, listen: false);
        provider.setRecordingPath(outputPath!);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final provider = Provider.of<RecordUploadProvider>(context, listen: false);
      provider.setRecordingPath(widget.videoPath);
      _loadVideo();
    });
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<RecordUploadProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              VideoViewer(trimmer: _trimmer),
              IconButton(onPressed: () async {
                bool playbackState = await _trimmer.videoPlaybackControl(
                  startValue: _startValue,
                  endValue: _endValue,
                );
                setState(() => _isPlaying = playbackState);
              }, icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 45,))
            ],
          ),
          Positioned(
            top: 65 ,
            left: 10,
            right: 10,
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
                            Text("Create a Feel", style: AppTextStyles.headingTextStyle3.copyWith(color: Colors.white),),
                            TextButton(onPressed: (){
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx)=> PublishReelPage()));
                            }, child: Text("Next", style: AppTextStyles.buttonTextStyle.copyWith(color: Colors.white),))
                          ],
                        ),

                      ],
                    ),
                  );
                }
            ),
          ),

          // if(_showTrimmer)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child:
              AnimatedOpacity(
                opacity: _showTrimmer ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 29, vertical: 5),
                  decoration: BoxDecoration(
                      gradient: AppGradients.primaryGradient,
                      borderRadius: BorderRadius.circular(24)
                  ),
                  child:  _buildTrimmerWidget()
                ),
              ),

            ),

          if(!_showTrimmer)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child:
              Container(
                padding: EdgeInsets.symmetric(horizontal: 29, vertical: 5),
                decoration: BoxDecoration(
                    gradient: AppGradients.primaryGradient,
                    borderRadius: BorderRadius.circular(24)
                ),
                child: _showPlaybackSpeed
                    ? _buildPlaybackSpeedWidget()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: ()=> setState(()=> _showTrimmer = true), icon: Column(
                      spacing: 4,
                      children: [
                        SvgPicture.asset(AppIcons.icTrim),
                        Text("Trim", style: AppTextStyles.captionTextStyle.copyWith(color: Colors.white),)
                      ],
                    )),
                    TextButton(onPressed: ()=> setState(()=> _showPlaybackSpeed = true), child: Column(
                      spacing: 4,
                      children: [
                        Text('${_provider.playbackSpeed.toInt()}x', style: AppTextStyles.headingTextStyle.copyWith(color: Colors.white)),
                        Text("Speed", style: AppTextStyles.captionTextStyle.copyWith(color: Colors.white),)
                      ],
                    )),
                    IconButton(onPressed: (){
                      if(_isMuted){
                        _isMuted = false;
                        _trimmer.videoPlayerController!.setVolume(1.0);
                        _trimmer.videoPlayerController!.play();
                        _provider.setMuted(false);
                        printToastMsg("Video is un muted!");
                      }else{
                        _isMuted = true;
                        _trimmer.videoPlayerController!.setVolume(0.0);
                        _trimmer.videoPlayerController!.play();
                        _provider.setMuted(false);
                        printToastMsg("Video is muted!");
                      }
                      setState(() {});
                    }, icon: Column(
                      spacing: 4,
                      children: [
                        SvgPicture.asset(_isMuted ? AppIcons.icMute : AppIcons.icVolumeUp),
                        Text(_isMuted ? "Unmute" : "Mute", style: AppTextStyles.captionTextStyle.copyWith(color: Colors.white),)
                      ],
                    )),
                  ],
                ),
              ),

            )
        ],
      ),

    );
  }

  Widget _buildTrimmerWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // AppBar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:  [
            Row(
              spacing: 5,
              children: [
                Icon(Icons.close, color: Colors.white,),
                Text('Trim Video', style: AppTextStyles.smallTextStyle.copyWith(color: Colors.white)),
              ],
            ),
            TextButton(onPressed: (){
              setState(()=> _showTrimmer = false);
              _saveVideo();
            }, child: Text('DONE', style: TextStyle(color: Colors.white, fontSize: 18))),
          ],
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TrimViewer(
            trimmer: _trimmer,
            viewerHeight: 50.0,
            viewerWidth: double.infinity,
            durationStyle: DurationStyle.FORMAT_MM_SS,
            type: ViewerType.fixed,
            maxVideoLength: _trimmer.videoPlayerController != null ? _trimmer.videoPlayerController!.value.duration : Duration(seconds: 30),
            editorProperties: TrimEditorProperties(
              borderPaintColor: Colors.white,
              borderWidth: 4,
              borderRadius: 12,
              circlePaintColor: Colors.yellow.shade800,
            ),
            areaProperties: TrimAreaProperties.edgeBlur(
              thumbnailQuality: 50,
            ),
            onChangeStart: (value) => _startValue = value,
            onChangeEnd: (value) => _endValue = value,
            onChangePlaybackState: (value) =>
                setState(() => _isPlaying = value),
          ),
        ),
        // Duration Info
        /*   Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Video Duration 56s',
                      style: TextStyle(color: Colors.white.withOpacity(0.7))),
                  Text('Trimmed Duration 30s',
                      style: TextStyle(color: Colors.white.withOpacity(0.7))),
                ],
              ),
            )*/
      ],
    );
  }

  Widget _buildPlaybackSpeedWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 10,
              children: [
                Icon(Icons.close, color: Colors.white,),
                Text("Playback Speed", style: AppTextStyles.smallTextStyle.copyWith(color: Colors.white),)
              ],
            ),
            TextButton(onPressed: ()=> setState(() => _showPlaybackSpeed = false), child: Text("DONE", style: AppTextStyles.smallTextStyle.copyWith(color: Colors.white),))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPlaybackSpeedItem(playbackSpeed: 0.5),
            _buildPlaybackSpeedItem(playbackSpeed: 1),
            _buildPlaybackSpeedItem(playbackSpeed: 2),
            _buildPlaybackSpeedItem(playbackSpeed: 3),

          ],
        )
      ],
    );
  }

  Widget _buildPlaybackSpeedItem({required double playbackSpeed}) {
    bool isSelected = _provider.playbackSpeed == playbackSpeed;
    String playbackSpeedTxt = playbackSpeed % 1 == 0 ? playbackSpeed.ceil().toString() : playbackSpeed.toString();
    return TextButton(onPressed: () {
      _provider.setPlaybackSpeed(playbackSpeed);
      _trimmer.videoPlayerController!.setPlaybackSpeed(playbackSpeed);
      _trimmer.videoPlayerController!.play();
    },
        child: Text("${playbackSpeedTxt}x",
          style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w300),));
  }

  void printToastMsg(String msg){
    Fluttertoast.showToast(msg: msg);
  }

  void _loadVideo() async {
    await _trimmer.loadVideo(videoFile: File(widget.videoPath));
  }
}