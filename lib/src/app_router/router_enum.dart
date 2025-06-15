/*
enum RouterEnum {
  welcomeView('/welcome_view'),
  loginView('/login_view'),
  personalizationView('/personalization_view'),
  searchView('/search_view'),

  homeView('/home_view'),
  discoverView('/discover_view'),
  notificationView('/notification_view'),
  profileView('/profile_view');

  final String routeName;

  const RouterEnum(this.routeName);
}*/

enum RouterEnum {
  dashboardView('/dashboard_view'),
  videoFeedView('/video_feed_view'),
  profileView('/profile_view');

  final String routeName;

  const RouterEnum(this.routeName);
}
