import 'package:flutter/cupertino.dart';

class AppGradients {
  static
  final LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color.fromRGBO(255, 251, 235, 1),
      Color.fromRGBO(204, 255, 236, 1),
      Color.fromRGBO(223, 255, 186, 1),
      Color.fromRGBO(229, 204, 255, 1),
      Color.fromRGBO(204, 229, 255, 1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}