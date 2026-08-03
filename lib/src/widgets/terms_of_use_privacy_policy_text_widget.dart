import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/res/app_constants.dart';
import '../helpers/url_launcher_helper.dart';
import '../res/app_colors.dart';
import '../res/app_textstyles.dart';

class TermsOfUsePrivacyPolicyTextWidget extends StatelessWidget {
  const TermsOfUsePrivacyPolicyTextWidget({
    super.key,
    this.comingForRegistration = false,
    this.textColor
  });

  final bool comingForRegistration;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    return RichText(
        textAlign: .start,
        text: TextSpan(children: [
          TextSpan(
              text: comingForRegistration
                  ? "By creating account, you accept our "
                  : "By purchasing this subscription, you accept our ",
              style: AppTextStyles.smallTextStyle.copyWith(fontFamily: AppConstants.appFontFamily, color: textColor ?? AppColors.greyTextColor)
          ),
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () => UrlLauncherHelper.launchUri(url: AppConstants.termsOfUseUrl),
            text: "Terms of use (EULA) ",
            style: AppTextStyles.smallTextStyle.copyWith(color: AppColors.primaryColor, decoration: .underline, fontFamily: AppConstants.appFontFamily, decorationColor: AppColors.primaryColor, fontWeight: .w600),
          ),
          TextSpan(
              text: "and ",
              style: AppTextStyles.smallTextStyle.copyWith(fontFamily: AppConstants.appFontFamily, color: textColor  ?? AppColors.greyTextColor)
          ),
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () => UrlLauncherHelper.launchUri(url: AppConstants.privacyPolicyUrl),
            text: "Privacy Policy",
            style: AppTextStyles.smallTextStyle.copyWith(color: AppColors.primaryColor, decoration: .underline, fontFamily: AppConstants.appFontFamily, decorationColor: AppColors.primaryColor, fontWeight: .w600),
          ),
        ]));
  }
}