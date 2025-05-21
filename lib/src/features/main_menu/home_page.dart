import 'package:circle_wheel_scroll/circle_wheel_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../res/app_colors.dart' show AppColors;
import '../../res/app_textstyles.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});
  Widget _buildItem(int i) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          padding: EdgeInsets.all(20),
          color: Colors.blue[100 * ((i % 8) + 1)],
          child: Center(
            child: Text(
              i.toString(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // height: 260,
        // width: 160,
        child: CircleListScrollView(
          physics: CircleFixedExtentScrollPhysics(),
          axis: Axis.horizontal,
          itemExtent: 80,
          children: List.generate(20, _buildItem),
          radius: MediaQuery.of(context).size.width * 0.6,
        ),
      ),
    );
  }
}