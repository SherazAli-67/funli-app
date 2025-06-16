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
  welcomeView('/welcome_view'),
  loginView('/login_view'),
  signupView('/signup_view'),
  forgetPassView('/forgetPass_view'),
  personalizationView('/personalization_view'),
  searchView('/search_view'),
  //BottomNav
  discoverView('/discover_view'),
  videoFeedView('/video_feed_view'),
  notificationView('/notification_view'),
  profileView('/profile_view');

  final String routeName;

  const RouterEnum(this.routeName);
}
