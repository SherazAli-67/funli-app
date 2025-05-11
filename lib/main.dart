import 'package:flutter/material.dart';
import 'package:funli_app/src/features/personalization/personalization_page.dart';
import 'package:funli_app/src/providers/personal_info_provider.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/features/welcome_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> PersonalInfoProvider())
      ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: AppConstants.appFontFamily,
        scaffoldBackgroundColor: Colors.white
      ),
      home: PersonalizationPage(),
    );
  }
}
