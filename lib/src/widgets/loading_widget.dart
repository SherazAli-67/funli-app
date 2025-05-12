import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget{
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Platform.isIOS ? CupertinoActivityIndicator(color: Colors.white,) : CircularProgressIndicator(color: Colors.white,),);
  }

}