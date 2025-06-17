import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/features/authentication/signup_page.dart';
import 'package:funli_app/src/features/hashtagged_reels_page/hashtag_reels_page.dart';
import 'package:funli_app/src/features/main_menu/discover_page/discover_page.dart';
import 'package:funli_app/src/features/main_menu/discover_page/filtered_reels_page.dart';
import 'package:funli_app/src/features/main_menu/notifications/notification_page.dart';
import 'package:funli_app/src/features/main_menu/profile/edit_profile_page.dart';
import 'package:funli_app/src/features/main_menu/profile/remote_user_profile_page.dart';
import 'package:funli_app/src/features/main_menu/profile/user_profile_page.dart';
import 'package:funli_app/src/features/main_menu/home_reels_page/video_feed_view.dart';
import 'package:funli_app/src/features/mood_reels_page/mood_reels_page.dart';
import 'package:funli_app/src/features/personalization/personalization_page.dart';
import 'package:funli_app/src/features/search_page.dart';
import 'package:funli_app/src/features/settings/content_preferences_page.dart';
import 'package:funli_app/src/features/settings/help_center_page.dart';
import 'package:funli_app/src/features/settings/privacy_security.dart';
import 'package:funli_app/src/features/settings/profile_settings_page.dart';
import 'package:funli_app/src/features/settings/report_problem_page.dart';
import 'package:funli_app/src/features/settings/terms_privacy_page.dart';
import 'package:funli_app/src/features/upload_feel/create_upload_feel_page.dart';
import 'package:funli_app/src/features/upload_feel/edit_uploaded_feel.dart';
import 'package:funli_app/src/features/upload_feel/publish_reel_page.dart';
import 'package:funli_app/src/features/welcome_page.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/login_page.dart';
import '../features/reels_page/updated_reels_page.dart';
import 'bottom_navigation_widget.dart';
import 'custom_page_builder_widget.dart';


final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class AppRouter {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    observers: [routeObserver],
    initialLocation: RouterEnum.videoFeedView.routeName,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder: (context, state, child) => customPageBuilderWidget(
          context,
          state,
          BottomNavigationWidget(
            location: state.uri.toString(),
            backgroundColor:
            state.uri.toString() == RouterEnum.discoverView.routeName
                ? Colors.black
                : null,
            child: child,
          ),
        ),
        routes: [
          GoRoute(
            path: RouterEnum.videoFeedView.routeName,
            pageBuilder: (context, state) => customPageBuilderWidget(
              context,
              state,
              SizedBox.expand(child: const VideoFeedView()),
            ),
          ),
          GoRoute(
            path: RouterEnum.notificationView.routeName,
            pageBuilder: (context, state) => customPageBuilderWidget(
              context,
              state,
              const NotificationPage(),
            ),
          ),
          GoRoute(
            path: RouterEnum.discoverView.routeName,
            pageBuilder: (context, state) => customPageBuilderWidget(
              context,
              state,
              const DiscoverPage(),
            ),
          ),
          GoRoute(
            path: RouterEnum.profileView.routeName,
            pageBuilder: (context, state) => customPageBuilderWidget(
              context,
              state,
              const UserProfilePage(),
            ),
          ),
        ],
      ),

      GoRoute(
        path: RouterEnum.welcomeView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const WelcomePage(),
      ),
      GoRoute(
        path: RouterEnum.loginView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const LoginPage(),
      ),
      GoRoute(
        path: RouterEnum.signupView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const SignupPage(),
      ),
      GoRoute(
        path: RouterEnum.personalizationView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const PersonalizationPage(),
      ),
      GoRoute(
        path: RouterEnum.searchView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const SearchPage(),
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
            child: RemoteUserProfilePage(userID: extras['userID'], userName: extras['userName'], profilePicture: extras['profilePicture'],)
          );
        },
      ),
      GoRoute(
        path: RouterEnum.profileSettingsView.routeName,
        builder: (BuildContext context, GoRouterState state) =>
        const ProfileSettingsPage(),
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
            ),
          );
        },
      ),
    ],
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final goingTo = state.matchedLocation;

      // Routes that don't require auth
      final publicPaths = [
        RouterEnum.welcomeView.routeName,
        RouterEnum.loginView.routeName,
        RouterEnum.signupView.routeName,
      ];

      if (!loggedIn && !publicPaths.contains(goingTo)) {
        // Not logged in and trying to access a private route
        return RouterEnum.welcomeView.routeName;
      }

      if (loggedIn && publicPaths.contains(goingTo)) {
        // Logged in and trying to access public route (e.g., login or welcome)
        return RouterEnum.videoFeedView.routeName;
      }

      return null;
    },
  );
}


