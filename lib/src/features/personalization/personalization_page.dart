import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/bloc_cubit/auth_cubit.dart';
import 'package:funli_app/src/bloc_cubit/auth_states.dart';
import 'package:funli_app/src/features/main_menu/main_menu_page.dart';
import 'package:funli_app/src/features/personalization/age_gender_page.dart';
import 'package:funli_app/src/features/personalization/interest_page.dart';
import 'package:funli_app/src/features/personalization/mood_detection_setup.dart';
import 'package:funli_app/src/helpers/snackbar_messages_helper.dart';
import 'package:funli_app/src/providers/personal_info_provider.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/widgets/app_back_button.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/secondary_btn.dart';
import 'package:provider/provider.dart';

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
    // MoodDetectionSetup()
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
            Expanded(
                child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index)=> setState(() => _currentPage = index),
                itemBuilder: (ctx, index){
              return _pages[_currentPage];
            })),
            BlocConsumer<AuthCubit, AuthStates>(
              listener: (_, state){
                if(state is CompletedUserSignupInfoFailed){
                  SnackbarMessagesHelper.showSnackBarMessage(context: context, title: "Failed to Update!", message: state.errorMessage, isError: true);
                }else if(state is CompletedUserSignupInfo){
                  SnackbarMessagesHelper.showSnackBarMessage(context: context, title: AppConstants.accountSetupSuccessTitle, message: AppConstants.accountSetupSuccessMessage);
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> MainMenuPage()), (val)=> false);
                }
              },
              builder: (_, state) {


                return _currentPage == _pages.length-1
                    ? SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 22),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 17,
                      children: [
                        Expanded(child: SecondaryBtn(btnText: "Back", icon: AppIcons.icArrowBack, onTap: (){
                          _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                        }, isPrefix: true,)),
                        Expanded(child: PrimaryBtn(btnText: "Let’s Go!", icon: AppIcons.icArrowNext, onTap: (){
                          final infoProvider = Provider.of<PersonalInfoProvider>(context, listen: false);
                          DateTime dob = DateTime(infoProvider.selectedYear, infoProvider.selectedMonth, infoProvider.selectedDay);
                          List<String> interests = infoProvider.selectedInterests;

                          context.read<AuthCubit>().onCompleteUserSignup(dob: dob, interests: interests, gender: infoProvider.selectedGender);
                         /* Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_)=> MoodDetectionSetup()), (val)=> false);*/
                        }, isLoading: state is CompletingUserSignupInfo,))
                      ],
                    ),
                  ),
                )
                    : PrimaryBtn(btnText: "Next", icon: AppIcons.icArrowNext, onTap: (){
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                }, isLoading: state is CompletingUserSignupInfo,);
              }
            ),
            InkWell(
                onTap: (){}, child: Text("Skip for now", style: AppTextStyles.buttonTextStyle,))
          ],
        ),
      )),
    );
  }
}