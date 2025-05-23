import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_textstyles.dart';

class CommentsPage extends StatelessWidget{
  const CommentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 28),
      child: Column(
        spacing: 14,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Comments (204,755)', style: AppTextStyles.headingTextStyle3,),
              IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.lightGreyColor
                  ),
                  onPressed: (){}, icon: Icon(Icons.close))
            ],
          ),
        ],
      ),
    );
  }

}