import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/features/authentication/forget_password_page.dart';
import 'package:funli_app/src/features/authentication/signup_page.dart';
import 'package:funli_app/src/features/deep_link_handler.dart';
import 'package:funli_app/src/features/hashtagged_reels_page/hashtag_reels_page.dart';
import 'package:funli_app/src/features/main_menu/discover_page/discover_page.dart';
import 'package:funli_app/src/features/main_menu/discover_page/filtered_reels_page.dart';
import 'package:funli_app/src/features/main_menu/homepage/homepage.dart';
import 'package:funli_app/src/features/main_menu/main_menu_page.dart';
import 'package:funli_app/src/features/main_menu/notifications/notification_page.dart';
import 'package:funli_app/src/features/main_menu/profile/edit_profile_page.dart';
import 'package:funli_app/src/features/main_menu/profile/remote_user_profile_page.dart';
import 'package:funli_app/src/features/main_menu/profile/user_profile_page.dart';
import 'package:funli_app/src/features/main_menu/video_feed_view/video_feed_view.dart';
import 'package:funli_app/src/features/mood_reels_page/mood_reels_page.dart';
import 'package:funli_app/src/features/personalization/personalization_page.dart';
import 'package:funli_app/src/features/profile_analytics_dashboard/profile_analytics_dashboard.dart';
import 'package:funli_app/src/features/report_content/report_content_page.dart';
import 'package:funli_app/src/features/search_page.dart';
import 'package:funli_app/src/features/settings/content_preferences_page.dart';
import 'package:funli_app/src/features/settings/help_center_page.dart';
import 'package:funli_app/src/features/settings/privacy_security.dart';
import 'package:funli_app/src/features/settings/profile_settings_page.dart';
import 'package:funli_app/src/features/settings/report_problem_page.dart';
import 'package:funli_app/src/features/settings/terms_privacy_page.dart';
import 'package:funli_app/src/features/upload_feel/create_upload_feel_page.dart';
import 'package:funli_app/src/features/upload_feel/edit_uploaded_feel.dart';
import 'package:funli_app/src/features/upload_feel/publish_draft_page.dart';
import 'package:funli_app/src/features/upload_feel/publish_reel_page.dart';
import 'package:funli_app/src/features/welcome_page.dart';
import 'package:funli_app/src/providers/feels_search_provider.dart';
import 'package:funli_app/src/providers/hashtag_search_provider.dart';
import 'package:funli_app/src/providers/report_content_provider.dart';
import 'package:funli_app/src/providers/users_search_provider.dart';
import 'package:funli_app/src/widgets/video_player_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/authentication/login_page.dart';
import '../features/reels_page/updated_reels_page.dart';



final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root',);
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class AppRouter {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    observers: [routeObserver],
    initialLocation: RouterEnum.welcomeView.routeName,
    routes: [
      StatefulShellRoute.indexedStack(
          builder: (_, state, navigationShell)=> MainMenuPage(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: RouterEnum.homeView.routeName, builder: (ctx, state) => Homepage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: RouterEnum.discoverView.routeName,
                  builder: (ctx, state) => DiscoverPage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: RouterEnum.notificationView.routeName,
                  builder: (ctx, state) => NotificationPage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: RouterEnum.profileView.routeName,
                  builder: (ctx, state) => UserProfilePage()),
            ]),
          ]),

      GoRoute(path: RouterEnum.videoFeedView.routeName,
          builder: (ctx, state) => VideoFeedView()),
      GoRoute(
        path: RouterEnum.welcomeView.routeName,
        builder: (BuildContext context, GoRouterState state) => const WelcomePage(),
      ),
      GoRoute(
        path: RouterEnum.loginView.routeName,
        builder: (BuildContext context, GoRouterState state) => const LoginPage(),),
      GoRoute(
        path: RouterEnum.forgetPassView.routeName,
        builder: (BuildContext context, GoRouterState state) => const ForgetPasswordPage(),),
      GoRoute(
        path: RouterEnum.signupView.routeName,
        builder: (BuildContext context, GoRouterState state) => const SignupPage(),),
      GoRoute(
        path: RouterEnum.personalizationView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const PersonalizationPage(),
      ),
      GoRoute(
        path: RouterEnum.searchView.routeName,
        builder: (BuildContext context, GoRouterState state) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FeelsSearchProvider()..fetchInitial()),
            ChangeNotifierProvider(create: (_) => UsersSearchProvider()..fetchInitial()),
            ChangeNotifierProvider(create: (_) => HashtagSearchProvider()..fetchInitial()),
          ],
          child: const SearchPage(),
        ),
      ),
      GoRoute(
        path: RouterEnum.moodReelsView.routeName,
        pageBuilder: (context, state) {
          final extras = state.extra! as Map<String, dynamic>;
          return MaterialPage(
            child: MoodReelsPage(mood: extras['mood']),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.hashtagsReelsView.routeName,
        pageBuilder: (context, state) {
          final extras = state.extra! as Map<String, dynamic>;
          return MaterialPage(
            child: HashtagReelsPage(hashtag: extras['tag']),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.filteredReelsView.routeName,
        pageBuilder: (context, state) {
          final extras = state.extra! as Map<String, dynamic>;
          return MaterialPage(
            child: FilteredReelsPage(filter: extras['filter']),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.remoteUserProfileView.routeName,
        pageBuilder: (context, state) {
          final extras = state.extra! as Map<String, dynamic>;
          return MaterialPage(
              child: RemoteUserProfilePage(userID: extras['userID'],
                userName: extras['userName'],
                profilePicture: extras['profilePicture'],)
          );
        },
      ),
      GoRoute(
        path: RouterEnum.profileSettingsView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const ProfileSettingsPage(),
      ),
      GoRoute(
        path: RouterEnum.profileAnalyticsView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const ProfileAnalyticsDashboard(),
      ),
      GoRoute(
        path: RouterEnum.updateProfileView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const EditProfilePage(),
      ),
      GoRoute(
        path: RouterEnum.securityAndPrivacyView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const PrivacySecurity(),
      ),
      GoRoute(
        path: RouterEnum.contentPreferenceView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const ContentPreferencesPage(),
      ),
      GoRoute(
        path: RouterEnum.reportAProblemView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const ReportProblemPage(),
      ),
      GoRoute(
        path: RouterEnum.helpCenterView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const HelpCenterPage(),
      ),
      GoRoute(
        path: RouterEnum.termsAndPrivacyView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const TermsPrivacyPage(),
      ),
      GoRoute(
        // Add the parentNavigatorKey to use the root navigator
        parentNavigatorKey: _rootNavigatorKey,
        path: RouterEnum.createUploadReelView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const CreateUploadFeelPage(),
      ),
      GoRoute(
        path: RouterEnum.editUploadedReelView.routeName,
        pageBuilder: (context, state) {
          final extras = state.extra! as Map<String, dynamic>;

          return MaterialPage(
            child: EditUploadedFeelPage(
              videoPath: extras['videoPath'],
            ),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.publishDraftView.routeName,
        pageBuilder: (context, state) {
          final extras = state.extra! as Map<String, dynamic>;
          return MaterialPage(
            child: PublishDraftPage(
              reel: extras['reel'],
            ),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.videoPlayerView.routeName,
        pageBuilder: (context, state) {
          final extras = state.extra! as Map<String, dynamic>;
          return MaterialPage(
            child: VideoPlayerWidget(
              localPath: extras['localPath'],
              videoUrl: extras['videoUrl'],
            ),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.publishReelView.routeName,
        builder: (BuildContext context, GoRouterState state) => const PublishReelPage(),
      ),
      GoRoute(
        path: RouterEnum.updatedReelsView.routeName,
        pageBuilder: (context, state) {
          final extras = state.extra! as Map<String, dynamic>;

          return MaterialPage(
            child: UpdatedReelsPage(
              initialReels: extras['initialReels'],
              selectedIndex: extras['selectedIndex'],
              lastDocument: extras['lastDocument'],
              comingFrom: extras['comingFrom'],
              userID: extras['userID'],
              mood: extras['mood'],
              tag: extras['tag'],
              filterContext: extras['filterContext'],
            ),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.reportContentView.routeName,
        pageBuilder: (context, state) {
          final extras = state.extra! as Map<String, dynamic>;

          return MaterialPage(
            child: ChangeNotifierProvider(
              create: (_)=> ReportContentProvider(),
              child: ReportContentPage(
                reel: extras['reel'],
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.deepLinkViewer.routeName,
        pageBuilder: (context, state) {
          final extras = state.extra! as Map<String, dynamic>;

          return MaterialPage(
            child: DeepLinkHandler(
              reelID: extras['reelID'],
            ),
          );
        },
      ),

     /* GoRoute(
        path: RouterEnum.updatedFeedView.routeName,
        pageBuilder: (context, state) {
          final extras = state.extra! as Map<String, dynamic>;

          return MaterialPage(
            child: UpdatedFeedView(
              initialReels: extras['initialReels'],
              selectedIndex: extras['selectedIndex'],
            ),
          );
        },
      ),*/

    ],
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final goingTo = state.matchedLocation;

      // Routes that don't require auth
      final publicPaths = [
        RouterEnum.welcomeView.routeName,
        RouterEnum.loginView.routeName,
        RouterEnum.signupView.routeName,
        RouterEnum.forgetPassView.routeName,
      ];

      if (!loggedIn && !publicPaths.contains(goingTo)) {
        // Not logged in and trying to access a private route
        return RouterEnum.welcomeView.routeName;
      }

      if (loggedIn && publicPaths.contains(goingTo)) {
        // Logged in and trying to access public route (e.g., login or welcome)
        return RouterEnum.homeView.routeName;
      }

      return null;
    },
  );
}
