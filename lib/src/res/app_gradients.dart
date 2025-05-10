import 'package:flutter/cupertino.dart';

class AppGradients {
  static final LinearGradient primaryGradient = LinearGradient(
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

  static final LinearGradient btnGradient = LinearGradient(
    colors: [
      Color.fromRGBO(255, 215, 0, 1),
      Color.fromRGBO(138, 43, 226, 1),
      Color.fromRGBO(208, 34, 37, 1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}