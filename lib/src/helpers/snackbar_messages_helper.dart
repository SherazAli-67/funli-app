import 'package:flutter/material.dart';

import '../res/app_textstyles.dart';

class SnackbarMessagesHelper {
  static void showErrorSnacbarMessage({required BuildContext context, required String title, required String message}){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.subHeadingTextStyle,),
            Text(message, style: AppTextStyles.bodyTextStyle,)
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}