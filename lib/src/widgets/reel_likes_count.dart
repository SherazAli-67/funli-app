import 'package:flutter/material.dart';

import '../helpers/formatting_helpers.dart';

class ReelLikesCountWidget extends StatelessWidget{
  final int? count;

  const ReelLikesCountWidget({super.key, this.count});


  @override
  Widget build(BuildContext context) {
    return Text( count != null ?
    FormatingHelpers.formatNumber(count!) : '',
      style: TextStyle(fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white),);
  }

}