import 'package:flutter/material.dart';
import 'package:funli_app/src/features/main_menu/main_menu_page.dart';
import 'package:funli_app/src/features/personalization/age_gender_page.dart';
import 'package:funli_app/src/features/personalization/interest_page.dart';
import 'package:funli_app/src/features/personalization/mood_detection_page.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';

class PersonalizationPage extends StatefulWidget{
  const PersonalizationPage({super.key});

  @override
  State<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  final _pageController = PageController();

  final List<Widget> _pages = [
    AgeGenderPage(),
    InterestPage(),
    MoodDetectionPage()
  ];
  int _currentPage = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24),
        child: Column(
          spacing: 14,
          children: [
            Row(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBackButton(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 14,
                  children: [
                    Text("Personalization", style: AppTextStyles.headingTextStyle3,),
                    Text("Nice Job! Let’s personalize ${AppConstants.appTitle} for you"),
                  ],
                )
              ],
            ),
            Expanded(child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index)=> setState(() => _currentPage = index),
                itemBuilder: (ctx, index){
              return _pages[_currentPage];
            })),
            PrimaryBtn(btnText: "Next", icon: AppIcons.icArrowNext, onTap: (){
              if(_currentPage == _pages.length-1){
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> MainMenuPage()), (val)=> false);
              }else{
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
              }
            })
          ],
        ),
      )),
    );
  }
}