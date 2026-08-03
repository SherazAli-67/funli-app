import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {

  static Future<void> launchEmail({
    required String emailAddress,
  }) async {
    try {
      final Uri uri = Uri(
        scheme: 'mailto',
        path: emailAddress,
        queryParameters: {
          'subject': 'Support',
          'body': '',
        },
      );

      debugPrint(uri.toString());

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint("Cannot launch: $uri");
      }
    } catch (e) {
      throw Exception("Error launching email: $e");
    }
  }



  static Future<void> launchUri({required String url}) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
    );
    if (!launched) {
      throw Exception('Could not launch $url');
    }
  }
}