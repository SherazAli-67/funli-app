import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget{
  const LoadingWidget({super.key, Color color = Colors.white}): _color = color;
  final Color _color;
  @override
  Widget build(BuildContext context) {
    return Center(child: Platform.isIOS ? CupertinoActivityIndicator(color: _color) : CircularProgressIndicator(color: _color),);
  }

}