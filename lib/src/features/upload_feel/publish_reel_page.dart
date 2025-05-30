import 'dart:io';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/features/main_menu/main_menu_page.dart';
import 'package:funli_app/src/providers/size_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/mood_selecting_scroll_wheel_widget.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../providers/record_upload_provider.dart';
import '../../res/spacing_constants.dart';
import '../../testing/social_media/enhanced_social_text_field.dart';

class PublishReelPage extends StatefulWidget{
  const PublishReelPage({super.key});

  @override
  State<PublishReelPage> createState() => _PublishReelPageState();
}

class _PublishReelPageState extends State<PublishReelPage> {
  String visibility = 'Public';
  VideoPlayerController? _controller;

  TextEditingController captionController = TextEditingController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){

      final provider = Provider.of<RecordUploadProvider>(context, listen: false);
      _controller = VideoPlayerController.file(File(provider.recordedPath!))
        ..initialize().then((_) {
          setState(() {}); // Refresh to show the initialized video
          _controller!.setVolume(provider.isMuted ? 0.0 : 1.0);
          _controller!.setPlaybackSpeed(provider.playbackSpeed);
          // _controller.play(); // Auto-play
        });
    });
    setState(() {});
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecordUploadProvider>(context);
    Size size = Provider.of<SizeProvider>(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: provider.isCompressingVideo ? Colors.black54 :Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: AppBackButton(),
        ),
        centerTitle: false,
        leadingWidth: 45,
        title: Text("Create a Feel", style: AppTextStyles.headingTextStyle3,),
          actions: [
            PopupMenuButton(
              position: PopupMenuPosition.under,
                color: Colors.white,
                onSelected: (val)=> setState(() =>visibility = val.toString()),
                icon: Row(
                  children: [
                    Text(visibility, style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400),),
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
      body: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16.0),
            child: SizedBox(
              height: size.height*0.8,
              child: Column(
                spacing: 14,
                children: [
                  _feelingWidget((){
                    showModalBottomSheet(context: context, builder: (_){
                      return MoodSelectingScrollWheelWidget(onMoodChange: (mood){
                        provider.setCurrentMood(mood);
                      });
                    });
                  }, provider.currentMood),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child:  EnhancedSocialTextField(
                          hintText: "Write a caption here, to use hashtags type #hashtag",
                          maxLines: 5,
                          minLines: 3,

                          hashtagStyle: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.pinkColor),
                          mentionStyle: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.purpleColor, fontWeight: FontWeight.w600),
                          onChanged: (text) {
                            captionController.text = text;

                          },
                        ),),
                      Expanded(child: _controller != null ? Stack(
                        alignment: Alignment.center,
                        children: [
                          _controller!.value.isInitialized ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                          ) : LoadingWidget(),
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.primaryGradient
                            ),
                            child: IconButton(onPressed: (){
                              bool isPlaying = _controller!.value.isPlaying;
                              if(isPlaying){
                                _controller!.pause();
                              }else{
                                _controller!.play();
                              }
                            }, icon: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow_rounded, color: Colors.white,)),
                          )
                        ],
                      ) : LoadingWidget(),)
                    ],
                  ),
                  Image.asset(AppIcons.icComingSoonSpeaker),
                  const Spacer(),
                  Column(
                    spacing: 16,
                    children: [


                      PrimaryBtn(
                        btnText: "Publish",
                        icon: "",
                        onTap: _onPublishReelTap,
                        bgGradient: AppIcons.primaryBgGradient,
                        borderRadius: 16,),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: AppColors.textFieldBorderColor),
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: (){}, child: Text("Save as draft", style: AppTextStyles.buttonTextStyle.copyWith(color: Colors.black),)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          if(provider.isCompressingVideo)
            Container(
              height: size.height*0.9,
              width: double.infinity,
              color: Colors.black54,
            )
        ],
      ),
    );
  }

  Widget _feelingWidget(VoidCallback onTap, String currentMood, ){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.btnOuterGradient,
          boxShadow: [
            BoxShadow(
                color: Color(0xffC9BAFF),
                blurRadius: 17.6,
                offset: Offset(0, 6)
            )
          ],
          borderRadius: BorderRadius.circular(SpacingConstants.btnBorderRadius),
        ),
        // padding: EdgeInsets.all(2),
        child: Container(
          width: double.infinity,
          height: SpacingConstants.buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingConstants.btnBorderRadius),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(SpacingConstants.btnBorderRadius),
                child: Image.asset(AppIcons.primaryBgGradient, fit: BoxFit.cover, width: double.infinity, height: SpacingConstants.buttonHeight,),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text("Feeling ${AppData.getEmojiByMood(currentMood)} $currentMood", style: AppTextStyles.buttonTextStyle.copyWith(color: Colors.white),),
                    Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPublishReelTap() {
    String caption = captionController.text;
    context.read<RecordUploadProvider>().publishReel(caption: caption, visibility: visibility, navigationCallback: navigationCallback);

  }

  void navigationCallback(){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploading your video. You’ll be notified once it’s done.')),
    );
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> MainMenuPage()), (val)=> false);
  }
}