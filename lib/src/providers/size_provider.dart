import 'package:flutter/cupertino.dart';

class SizeProvider extends ChangeNotifier{
  double _height = 0;
  double _width = 0;

  double get height => _height;
  double get width => _width;
  Size get size => Size(_width, _height);
  void setSize(Size size){
    _height = size.height;
    _width = size.width;
  }
}