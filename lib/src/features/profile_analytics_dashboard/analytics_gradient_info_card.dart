import 'package:flutter/material.dart';

import '../../res/app_gradients.dart';
import '../../res/app_textstyles.dart';

class AnalyticsGradientInfoCard extends StatelessWidget{
  const AnalyticsGradientInfoCard({super.key, required this.topText, required this.mainText, required this.bottomText});
  final String topText, mainText, bottomText;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppGradients.primaryGradient,
      ),
      child: Column(
        children: [
          Text(
            topText,
            style: AppTextStyles.buttonTextStyle.copyWith(color: Colors.white),
          ),
          Text(
            mainText,
            style: AppTextStyles.headingTextStyle.copyWith(color: Colors.white),
          ),
          if (bottomText.isNotEmpty)
            Text(
              bottomText,
              style: AppTextStyles.buttonTextStyle.copyWith(color: Colors.white),
            ),
        ],
      ),
    );
  }

}