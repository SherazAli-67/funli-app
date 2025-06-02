import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/features/hashtagged_reels_page/hashtag_reels_page.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';

import '../res/app_textstyles.dart';

class AppTextWidget extends StatelessWidget {
  final String text;

  const AppTextWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');

    return RichText(
      text: TextSpan(
        children: words.map((word) {
          if (word.startsWith('#')) {
            return TextSpan(
              text: '$word ',
              style: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.purpleColor, fontFamily: AppConstants.appFontFamily),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> HashtagReelsPage(hashtag: word.substring(1, word.length))));
                },
            );
          } else {
            return TextSpan(
              text: '$word ',
              style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white, fontFamily: AppConstants.appFontFamily),
            );
          }
        }).toList(),
      ),
    );
  }
}