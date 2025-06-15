import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/bloc_cubit/auth_cubit.dart';
import 'package:funli_app/src/bloc_cubit/video_feed_cubit.dart';
import 'package:funli_app/src/dependancy_injection/dependency_injector.dart';
import 'package:funli_app/src/features/main_menu/main_menu_page.dart';
import 'package:funli_app/src/features/welcome_page.dart';
import 'package:funli_app/src/providers/feels_search_provider.dart';
import 'package:funli_app/src/providers/hashtag_search_provider.dart';
import 'package:funli_app/src/providers/mood_reels_provider.dart';
import 'package:funli_app/src/providers/personal_info_provider.dart';
import 'package:funli_app/src/providers/profile_provider.dart';
import 'package:funli_app/src/providers/record_upload_provider.dart';
import 'package:funli_app/src/providers/reels_provider.dart';
import 'package:funli_app/src/providers/size_provider.dart';
import 'package:funli_app/src/providers/tab_change_provider.dart';
import 'package:funli_app/src/providers/users_search_provider.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:provider/provider.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  injectionSetup();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> PersonalInfoProvider()),
        ChangeNotifierProvider(create: (_)=> MainMenuTabChangeProvider()),
        ChangeNotifierProvider(create: (_)=> RecordUploadProvider()),
        ChangeNotifierProvider(create: (_)=> ReelProvider()),
        ChangeNotifierProvider(create: (_)=> SizeProvider()),
        ChangeNotifierProvider(create: (_)=> ProfileProvider()..initUserProfile()),
        ChangeNotifierProvider(create: (_)=> MoodReelsProvider()),
        ChangeNotifierProvider(create: (_)=> FeelsSearchProvider()..fetchInitial()),
        ChangeNotifierProvider(create: (_)=> UsersSearchProvider()..fetchInitial()),
        ChangeNotifierProvider(create: (_)=> HashtagSearchProvider()..fetchInitial()),
      ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_)=> AuthCubit()),
        BlocProvider(create: (context) => getIt<VideoFeedCubit>(),)
      ],
      child: MaterialApp(
        title: AppConstants.appTitle, navigatorObservers: [routeObserver],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: AppConstants.appFontFamily,
          scaffoldBackgroundColor: Colors.white
        ),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                debugPrint("HasData: ${snapshot.requireData!.uid}");
                return MainMenuPage();
              } else {
                debugPrint("Do not has Data");
                return WelcomePage();
              }
            },
          )
      ),
    );
  }
}
