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

  static final LinearGradient uploadBtnGradient = LinearGradient(
    colors: [
      Color.fromRGBO(100, 149, 237, 1),
      Color.fromRGBO(138, 43, 226, 1),
      Color.fromRGBO(191, 244, 80, 1),
      Color.fromRGBO(127, 255, 212, 1),
      Color.fromRGBO(255, 215, 0, 1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient bottomNavigationBarGradient = LinearGradient(
    colors: [
      Color.fromRGBO(0, 0, 0, 1),
      Color.fromRGBO(34, 34, 34, 1),
      Color.fromRGBO(0, 0, 0, 1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}