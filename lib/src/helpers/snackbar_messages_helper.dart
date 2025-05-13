import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

import '../res/app_textstyles.dart';

class SnackbarMessagesHelper {
  static void showSnackBarMessage({required BuildContext context, required String title, required String message, bool isError = false}){
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        titleTextStyle: AppTextStyles.headingTextStyle3.copyWith(color: Colors.white),
        messageTextStyle: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white),
        contentType: isError ? ContentType.failure : ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);

   /* final materialBanner = MaterialBanner(
      elevation: 0,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType:  isError ? ContentType.failure : ContentType.success,
        // to configure for material banner
        inMaterialBanner: true,
      ),
      actions: const [SizedBox.shrink()],
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);*/
  }
}