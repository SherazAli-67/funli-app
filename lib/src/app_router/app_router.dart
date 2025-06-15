import 'package:flutter/material.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/features/main_menu/discover_page/discover_page.dart';
import 'package:funli_app/src/features/main_menu/notifications/notification_page.dart';
import 'package:funli_app/src/features/main_menu/profile/user_profile_page.dart';
import 'package:funli_app/src/features/main_menu/video_feed_view.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/login_page.dart';
import '../features/main_menu/main_menu_page.dart';
import '../features/personalization/personalization_page.dart';
import '../features/search_page.dart';
import '../features/upload_feel/create_upload_feel_page.dart';
import '../features/welcome_page.dart';
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
    ],
  );
}
/*class AppRouter {
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
            state.uri.toString() == RouterEnum.dashboardView.routeName
                ? Colors.black
                : null,
            child: child,
          ),
        ),
        routes: [
          GoRoute(
            path: RouterEnum.videoFeedView.routeName,
            pageBuilder:
                (context, state) => customPageBuilderWidget(
              context,
              state,
              const VideoFeedView(),
            ),
          ),
          GoRoute(
            path: RouterEnum.dashboardView.routeName,
            pageBuilder:
                (context, state) => customPageBuilderWidget(
              context,
              state,
              const DiscoverPage(),
            ),
          ),
          GoRoute(
            path: RouterEnum.profileView.routeName,
            pageBuilder:
                (context, state) => customPageBuilderWidget(
              context,
              state,
              const UserProfilePage(),
            ),
          ),
        ],
      ),
    ],
  );
}*/


