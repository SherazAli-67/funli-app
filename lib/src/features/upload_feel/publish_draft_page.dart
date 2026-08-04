import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_data.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/providers/size_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_gradients.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
import 'package:funli_app/src/widgets/loading_widget.dart';
import 'package:funli_app/src/widgets/mood_selecting_scroll_wheel_widget.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/secondary_btn.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../providers/record_upload_provider.dart';
import '../../res/firebase_constants.dart';
import '../../res/spacing_constants.dart';
import '../../testing/social_media/enhanced_social_text_field.dart';

class PublishDraftPage extends StatefulWidget{
  const PublishDraftPage({super.key, required ReelModel reel}) : _reel = reel;
  final ReelModel _reel;
  @override
  State<PublishDraftPage> createState() => _PublishDraftPageState();
}

class _PublishDraftPageState extends State<PublishDraftPage> {
  String visibility = 'Public';
  // VideoPlayerController? _controller;

  TextEditingController captionController = TextEditingController();
  @override
  void initState() {
    captionController.text = widget._reel.caption;
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
          child: GestureDetector(
            onTap: () {

            },
            child: AppBackButton(),
          ),
        ),
        centerTitle: false,
        leadingWidth: 45,
        title: Text("Publish Draft", style: AppTextStyles.headingTextStyle3,),
          actions: [
            PopupMenuButton(
              position: PopupMenuPosition.under,
                color: Colors.white,
                onSelected: (val)=> setState(() =>visibility = val.toString()),
                icon: Row(
                  children: [
                    Text(visibility, style: AppTextStyles.regularTextStyle.copyWith(fontWeight: FontWeight.w400),),
                    Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black,)
                  ],
                ),
                itemBuilder: (_){
              return [
                PopupMenuItem(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    value: 'Public',
                    child: Text("Public", style: AppTextStyles.regularTextStyle.copyWith(fontWeight: FontWeight.w400),)),
                PopupMenuItem(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    value: 'Private',
                    child: Text("Private", style: AppTextStyles.regularTextStyle.copyWith(fontWeight: FontWeight.w400),)),

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
                  _feelingWidget(() async {
                    final result = await showModalBottomSheet(
                        isDismissible: false,
                        context: context, builder: (_){
                      return MoodSelectingScrollWheelWidget(selectedMood: provider.currentMood,);
                    });

                    if(result != null){
                      provider.setCurrentMood(result);
                    }
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

                          hashtagStyle: AppTextStyles.regularTextStyle.copyWith(color: AppColors.pinkColor),
                          mentionStyle: AppTextStyles.regularTextStyle.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                          onChanged: (text) {
                            captionController.text = text;

                          },
                        ),),
                      Expanded(child: Stack(
                        alignment: Alignment.center,
                        children: [
                         ClipRRect(
                           borderRadius: BorderRadius.circular(10),
                           child: CachedNetworkImage(imageUrl: widget._reel.thumbnailUrl ?? AppIcons.icDefaultThumbnailUrl, fit: BoxFit.cover, height: 140),
                         ),
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.primaryGradient
                            ),
                            child: IconButton(onPressed: (){
                              context.push(RouterEnum.videoPlayerView.routeName, extra: {
                                'videoUrl': widget._reel.videoUrl
                              });

                            }, icon: Icon( Icons.play_arrow_rounded, color: Colors.white,)),
                          )
                        ],
                      ))
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
                            onPressed: (){
                              context.pop();
                            }, child: Text("Cancel", style: AppTextStyles.buttonTextStyle.copyWith(color: Colors.black),)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          if(provider.isCompressingVideo || provider.uploadProgress > 0)
            Container(
              height: size.height*0.9,
              width: double.infinity,
              color: Colors.black54,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingWidget(),
                  SizedBox(height: 16),
                  Text(
                    provider.isCompressingVideo 
                        ? "Preparing video for upload..."
                        : "Uploading: ${(provider.uploadProgress * 100).toStringAsFixed(0)}%",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
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

  void _onPublishReelTap() async{
   await context.read<RecordUploadProvider>().onUploadReelTap(reel: widget._reel);
   // Remove the draft from Firestore after successful publish
   try {
     String currentUID = FirebaseAuth.instance.currentUser!.uid;
     await FirebaseFirestore.instance
         .collection(FirebaseConstants.userCollection)
         .doc(currentUID)
         .collection(FirebaseConstants.draftsCollection)
         .doc(widget._reel.reelID)
         .delete();
     debugPrint("Draft deleted successfully from Firestore");
   } catch (e) {
     debugPrint("Error deleting draft: $e");
   }
   navigationCallback();
  }

  void navigationCallback()async{
    await showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context, builder: (ctx){
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Lottie.asset(AppIcons.icSuccessAnim, height: 150, repeat: false,),
            Text("Awesome! You  expressed your feelings☺", textAlign: TextAlign.center, style: AppTextStyles.headingTextStyle3,),
            Text("You can check feel uploading progress in the notification", textAlign: TextAlign.center, style: AppTextStyles.regularTextStyle,),

            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SecondaryBtn(btnText: "Go to 🏠 Home", icon: '', onTap: (){
                context.pop();
                _navigateBackToMainMenu();
              }),
            )
          ],
        ),
      );
    });

   debugPrint("Comes back in sheet");
   _navigateBackToMainMenu();
  }

  void _navigateBackToMainMenu(){
    context.pop();
  }
}
