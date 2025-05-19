import 'dart:io';

import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../providers/record_upload_provider.dart';

class PublishReelPage extends StatefulWidget{
  const PublishReelPage({super.key});

  @override
  State<PublishReelPage> createState() => _PublishReelPageState();
}

class _PublishReelPageState extends State<PublishReelPage> {
  String selectedPrivacyMode = 'Public';

  late VideoPlayerController _controller;



  @override
  void didChangeDependencies() {
    final provider = Provider.of<RecordUploadProvider>(context);
    _controller = VideoPlayerController.file(File(provider.recordedPath!))
      ..initialize().then((_) {
        setState(() {}); // Refresh to show the initialized video
        _controller.setVolume(provider.isMuted ? 0.0 : 1.0);
        _controller.setPlaybackSpeed(provider.playbackSpeed);
        // _controller.play(); // Auto-play
      });
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: AppBackButton(),
        ),
        leadingWidth: 45,
        title: Text("Create a Feel", style: AppTextStyles.headingTextStyle3,),
          actions: [
            PopupMenuButton(
              position: PopupMenuPosition.under,
                color: Colors.white,
                onSelected: (val)=> setState(() =>selectedPrivacyMode = val.toString()),
                icon: Row(
                  children: [
                    Text(selectedPrivacyMode, style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400),),
                    Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black,)
                  ],
                ),
                itemBuilder: (_){
              return [
                PopupMenuItem(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    value: 'Public',
                    child: Text("Public", style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400),)),
                PopupMenuItem(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    value: 'Private',
                    child: Text("Private", style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400),)),

              ];
            })
          ],
      ),
      body: SafeArea(child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: size.height*0.4,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.primaryGradient
                ),
                child: IconButton(onPressed: (){
                  bool isPlaying = _controller.value.isPlaying;
                  if(isPlaying){
                    _controller.pause();
                  }else{
                    _controller.play();
                  }
                }, icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow_rounded, color: Colors.white,)),
              )
            ],
          )
        ],
      )),
    );
  }
}