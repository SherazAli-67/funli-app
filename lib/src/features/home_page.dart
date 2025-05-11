import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_constants.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: Text("Welcome to ${AppConstants.appTitle}"),)),
    );
  }

}