import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/bloc_cubit/auth_cubit.dart';
import 'package:funli_app/src/features/welcome_page.dart';
import 'package:funli_app/src/providers/personal_info_provider.dart';
import 'package:funli_app/src/providers/tab_change_provider.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> PersonalInfoProvider()),
        ChangeNotifierProvider(create: (_)=> MainMenuTabChangeProvider()),

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
        BlocProvider(create: (_)=> AuthCubit())
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: AppConstants.appFontFamily,
          scaffoldBackgroundColor: Colors.white
        ),
          home: WelcomePage()
      ),
    );
  }
}
