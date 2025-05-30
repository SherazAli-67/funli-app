import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:funli_app/src/features/upload_feel/publish_reel_page.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

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
  late VideoPlayerController _controller;

  bool _showTrimmer = false;
  bool _showPlaybackSpeed = false;
  bool _isMuted = false;

  late RecordUploadProvider _provider;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {}); // Refresh to show the initialized video
        _controller.play(); // Auto-play
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<RecordUploadProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller),)
                : CircularProgressIndicator(),
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
                              _controller.pause();

                              provider.setRecordingPath(widget.videoPath);
                              Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> PublishReelPage()));
                            }, child: Text("Next", style: AppTextStyles.buttonTextStyle.copyWith(color: Colors.white),))
                          ],
                        ),

                      ],
                    ),
                  );
                }
            ),
          ),
          Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 29, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(24)
            ),
                child: _showTrimmer ? _buildTrimmerWidget() : _showPlaybackSpeed ? _buildPlaybackSpeedWidget() : Row(
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
                        Text("2x", style: AppTextStyles.headingTextStyle.copyWith(color: Colors.white)),
                        Text("Trim", style: AppTextStyles.captionTextStyle.copyWith(color: Colors.white),)
                      ],
                    )),
                    IconButton(onPressed: (){
                      if(_isMuted){
                        _isMuted = false;
                        _controller.setVolume(1.0);
                        _controller.play();
                        _provider.setMuted(false);
                        printToastMsg("Video is un muted!");
                      }else{
                        _isMuted = true;
                        _controller.setVolume(0.0);
                        _controller.play();
                        _provider.setMuted(false);
                        printToastMsg("Video is muted!");
                      }
                      setState(() {});
                    }, icon: Column(
                      spacing: 4,
                      children: [
                        SvgPicture.asset(_isMuted ? AppIcons.icMute : AppIcons.icVolumeUp),
                        Text("Sound", style: AppTextStyles.captionTextStyle.copyWith(color: Colors.white),)
                      ],
                    )),
                  ],
                ),
          ))
        ],
      ),

    );
  }

  Widget _buildTrimmerWidget() {
    return const SizedBox();
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
      _controller.setPlaybackSpeed(playbackSpeed);
      _controller.play();
    },
        child: Text("${playbackSpeedTxt}x",
          style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w300),));
  }

  void printToastMsg(String msg){
    Fluttertoast.showToast(msg: msg);
  }
}