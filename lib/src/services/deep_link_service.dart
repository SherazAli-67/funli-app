import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:uni_links/uni_links.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import '../app_router/app_router.dart';
import '../dependancy_injection/dependency_injector.dart';

class DeepLinkService {
  StreamSubscription? _sub;
  final AppRouter _appRouter = getIt<AppRouter>();
  final FirebaseDynamicLinks _dynamicLinks = FirebaseDynamicLinks.instance;

  void initDeepLinks() {
    // Listen for incoming links from uni_links
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        debugPrint('Received deep link via uni_links: $link');
        handleDeepLink(link);
      }  
    }, onError: (err) {
      debugPrint('Error listening to deep links: $err');
    });

    // Check for initial link if app was opened via deep link
    getInitialLink().then((String? initialLink) {
      if (initialLink != null) {
        debugPrint('Initial deep link received: $initialLink');
        handleDeepLink(initialLink);
      }
    });

    // Listen for Firebase Dynamic Links
    _initDynamicLinks();
  }

  Future<void> _initDynamicLinks() async {
    // Handle links that open the app
    final PendingDynamicLinkData? initialLink = await _dynamicLinks.getInitialLink();
    if (initialLink != null) {
      debugPrint('Initial dynamic link received: ${initialLink.link.toString()}');
      _handleDynamicLink(initialLink);
    }

    // Handle links that open the app in the foreground
    _dynamicLinks.onLink.listen(
      (dynamicLinkData) {
        debugPrint('Foreground dynamic link received: ${dynamicLinkData.link.toString()}');
        _handleDynamicLink(dynamicLinkData);
      },
      onError: (error) {
        debugPrint('Error handling dynamic link: $error');
      },
    );
  }

  void _handleDynamicLink(PendingDynamicLinkData data) {
    final Uri deepLink = data.link;
    handleDeepLink(deepLink.toString());
  }

  void handleDeepLink(String link) {
    // Parse the link and navigate accordingly
    Uri uri = Uri.parse(link);
    
    // Handle both custom scheme and https links
    if (uri.scheme == 'funliapp' || uri.host == 'funli-web.vercel.app') {
      if (uri.pathSegments.contains('reels') && uri.pathSegments.length > 1) {
        String reelId = uri.pathSegments.last;
        // Navigate to reel page with reelId
        debugPrint("ReelID in deepLinkService: $reelId");
        // Use a more robust way to ensure navigation after app initialization
        _appRouter.router.push(RouterEnum.deepLinkViewer.routeName, extra: {'reelID': reelId});
      } else if (uri.pathSegments.contains('profile') && uri.pathSegments.length > 1) {
        String userId = uri.pathSegments.last;
        // Navigate to profile page with userId
        navigateToProfile(userId);
      }
    }
  }



  void navigateToProfile(String userId) {
    // Implement navigation logic
    // Example: _appRouter.pushNamed('/profile', extra: userId);
  }

  /// Generates a Firebase Dynamic Link for sharing a specific reel
  Future<String> generateDeepLink(String reelId, String thumbnailUrl) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://funliapp.page.link',
      link: Uri.parse('https://funli-web.vercel.app/reels/$reelId'),
      androidParameters: AndroidParameters(
        packageName: 'com.funtech.funli',
        minimumVersion: 0,
      ),
      iosParameters: IOSParameters(
        bundleId: 'com.funtech.funli',
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out this FUNLI reel!',
        description: 'Watch this amazing reel on FUNLI app',
        imageUrl: Uri.parse(thumbnailUrl),
      ),
    );

    final ShortDynamicLink shortLink = await _dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }

  void dispose() {
    _sub?.cancel();
  }
}
