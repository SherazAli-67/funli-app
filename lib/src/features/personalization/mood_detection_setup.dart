import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/primary_gradient_background.dart';

import '../../res/app_constants.dart';
import '../../res/app_textstyles.dart';
import '../../widgets/app_back_button.dart';


class MoodDetectionSetup extends StatefulWidget {
  const MoodDetectionSetup({super.key});

  @override
  MoodDetectionSetupState createState() => MoodDetectionSetupState();
}

class MoodDetectionSetupState extends State<MoodDetectionSetup> with SingleTickerProviderStateMixin {
  CardState _cardState = CardState.camera;

  final _textEditingController = TextEditingController();
  late Size _size;
  

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return PrimaryGradientBackground(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 25,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 65.0, left: 16, right: 16, bottom: 16),
          child: Row(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackButton(color: Colors.white,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 14,
                children: [
                  Text("Mood Detection Setup", style: AppTextStyles.headingTextStyle3.copyWith(color: Colors.white),),
                  Text("Nice Job! Let’s personalize ${AppConstants.appTitle} for you", style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white),),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              GestureDetector(
                  onTap:(){
                    setState(() {
                      _cardState = CardState.camera;
                    });
                  },
                  child: _builCameraWidget()),

              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: _cardState == CardState.camera ? _size.height*0.55 : _size.height*0.1,
                right: 0,
                left: 0,
                bottom: 0,
                child: GestureDetector(
                    onTap: ()=> setState(() => _cardState = CardState.voice),
                    child: _buildYourVoiceWidget()),
              ),

              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top:  _cardState == CardState.text ? _size.height*0.2 : _size.height*0.65,
                right: 0,
                left: 0,
                bottom: 0,
                child: GestureDetector(
                    onTap: ()=> setState(() => _cardState = CardState.text),
                    child: _buildYourTextWidget()),
              ),
            ],
          ),
        )
      ],
    ),);
  }

  Widget _buildYourTextWidget() {
    bool isSelected = _cardState == CardState.text;
    return Container(
                decoration: BoxDecoration(
                    color: AppColors.tealColor,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: SizedBox(

                    height: _size.height*0.5,
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
                                  Text("Your Texts", style: AppTextStyles.buttonTextStyle.copyWith(fontWeight: FontWeight.w900, color: Colors.white),),
                                  Text("Type how you’re feeling today.", style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400, color: Colors.white),),
                                ],
                              ),
                            ),
                            if(!isSelected)
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.done, color: Colors.black, size: 20,),
                              )
                          ],
                        ),
                        
                        const SizedBox(height: 20,),
                        TextField(
                          controller: _textEditingController,
                          maxLines: null,
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Type your feelings here...",
                            hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white54)
                          ),
                        ),
                        const Spacer(),
                        PrimaryBtn(btnText: "Done", icon: AppIcons.icArrowNext, onTap: _onDoneTap)
                      ],
                    ),
                  ),
                ),
              );
  }

  Widget _builCameraWidget() {
    bool isSelected = _cardState == CardState.camera;
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
                      if(!isSelected)
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
                      child: Center(child: Text("Camera Goes here", style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400, color: Colors.white),),),
                    ),
                  ),
                  const SizedBox(height: 12,),
                  PrimaryBtn(btnText: "Done", icon: AppIcons.icArrowNext, onTap: (){})
                ],
              ),
            );
  }

  Widget _buildYourVoiceWidget() {
    bool isSelected = _cardState == CardState.voice;
    return Container(

                decoration: BoxDecoration(
                    color: AppColors.pinkColor,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: _size.height*0.5,
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
                                  Text("Your Voice", style: AppTextStyles.buttonTextStyle.copyWith(fontWeight: FontWeight.w900, color: Colors.white),),
                                  Text("Speak your mood and let ${AppConstants.appTitle} understand! 🗣️", style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400, color: Colors.white),),
                                ],
                              ),
                            ),
                            if(!isSelected)
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.done, color: Colors.black, size: 20,),
                              )
                          ],
                        ),
                        const SizedBox(height: 20,),
                        Center(
                          child: Column(
                            spacing: 20,
                            children: [
                              CircleAvatar(
                                  radius: 100,
                                  backgroundColor: Colors.white,
                                  child: Center(child: IconButton(onPressed: (){}, icon: SvgPicture.asset(AppIcons.icMic)))
                              ),
                              RichText(text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Tap & Hold ", style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: AppConstants.appFontFamily)
                                  ),
                                  TextSpan(
                                      text: "the button to speak your feelings", style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w400, fontFamily: AppConstants.appFontFamily)
                                  ),

                                ]
                              ))
                            ],
                          ),
                        ),
                        const Spacer(),
                        PrimaryBtn(btnText: "Done", icon: AppIcons.icArrowNext, onTap: (){})
                      ],
                    ),
                  ),
                ),
              );
  }

  
  void _onDoneTap(){
    showModalBottomSheet(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))
        ),
        context: context, builder: (ctx){
          return Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Image.asset(AppIcons.emojiHappyMoodDetected),
              Text("Got it, You are feeling happy! ☺",style: AppTextStyles.subHeadingTextStyle,textAlign: TextAlign.center,),
              Text("Now let’s get you to your feeds!", style: AppTextStyles.bodyTextStyle, textAlign: TextAlign.center,),
              const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: PrimaryBtn(btnText: "Lesss’go! 🚀", icon: '', onTap: (){}),
              )
            ],
          ),);
    });
  }
}

enum CardState { camera, voice, text }