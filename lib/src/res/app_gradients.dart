import 'package:flutter/cupertino.dart';

class AppGradients {
  /*static final LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color.fromRGBO(255, 251, 235, 1),
      Color.fromRGBO(204, 255, 236, 1),
      Color.fromRGBO(223, 255, 186, 1),
      Color.fromRGBO(229, 204, 255, 1),
      Color.fromRGBO(204, 229, 255, 1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );*/
  static final LinearGradient interestItemGradient = LinearGradient(
    colors: [
      // Color.fromRGBO(255, 59, 48, 0),
      // Color.fromRGBO(255, 149, 0, 0.5),
      Color.fromRGBO(255, 204, 0, 1),
      Color.fromRGBO(255, 204, 0, 1),
      Color.fromRGBO(52, 199, 89, 1),
      Color.fromRGBO(0, 122, 255, 1),
      Color.fromRGBO(88, 86, 214, 1),
      Color.fromRGBO(175, 82, 222, 1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color.fromRGBO(255, 59, 48, 1),
      Color.fromRGBO(255, 149, 0, 1),
      Color.fromRGBO(255, 204, 0, 1),
      Color.fromRGBO(255, 204, 0, 1),
      Color.fromRGBO(52, 199, 89, 1),
      Color.fromRGBO(0, 122, 255, 1),
      Color.fromRGBO(88, 86, 214, 1),
      Color.fromRGBO(175, 82, 222, 1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static final LinearGradient btnOuterGradient = LinearGradient(
    colors: [
      Color.fromRGBO(255, 215, 0, 1),
      Color.fromRGBO(138, 43, 226, 1),
      Color.fromRGBO(208, 34, 37, 1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient btnInnerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.12, 0.27, 0.46, 0.65, 0.79, 1.0],
    colors: [
      Color(0xFFFF3B30), // Red
      Color(0xFFFF9500), // Orange
      Color(0xFFFFCC00), // Yellow
      Color(0xFF34C759), // Green
      Color(0xFF007AFF), // Blue
      Color(0xFF5856D6), // Indigo
      Color(0xFFAF52DE), // Purple
    ],
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