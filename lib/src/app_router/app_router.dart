import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/features/authentication/signup_page.dart';
import 'package:funli_app/src/features/main_menu/discover_page/discover_page.dart';
import 'package:funli_app/src/features/main_menu/notifications/notification_page.dart';
import 'package:funli_app/src/features/main_menu/profile/user_profile_page.dart';
import 'package:funli_app/src/features/main_menu/home_reels_page/video_feed_view.dart';
import 'package:funli_app/src/features/personalization/personalization_page.dart';
import 'package:funli_app/src/features/search_page.dart';
import 'package:funli_app/src/features/welcome_page.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/login_page.dart';
import 'bottom_navigation_widget.dart';
import 'custom_page_builder_widget.dart';


final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);
class AppRouter {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
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
              const VideoFeedView(),
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


