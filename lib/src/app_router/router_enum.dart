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
  //auth and onboarding flow
  welcomeView('/welcome_view'),
  loginView('/login_view'),
  signupView('/signup_view'),
  forgetPassView('/forgetPass_view'),
  personalizationView('/personalization_view'),

  //rest pages

  searchView('/search_view'),
  updatedReelsView('/reels-view'),
  moodReelsView('/moodReels-view'),
  hashtagsReelsView('/hashtagReels-view'),
  filteredReelsView('/filteredReels-view'),
  remoteUserProfileView('/remoteUserProfile-view'),
  reelsViewerView('/reels-viewer-view'),

  //profile pages
  profileSettingsView('/profileSettings-view'),
  profileAnalyticsView('/profileAnalyticsView'),
  updateProfileView('updateProfile-view'),
  securityAndPrivacyView('/securityAndPrivacy-view'),
  contentPreferenceView('/contentPreference-view'),
  reportAProblemView('/reportAProblem-view'),
  helpCenterView('/helpCenter-view'),
  termsAndPrivacyView('/termsAndPrivacy-view'),

  //upload pages router setting
  createUploadReelView("/createUploadReel-view"),
  editUploadedReelView('/editUploadedReel-view'),
  publishReelView('/publishReel-view'),
  //BottomNav
  discoverView('/discover_view'),
  videoFeedView('/video_feed_view'),
  notificationView('/notification_view'),
  profileView('/profile_view');


  final String routeName;

  const RouterEnum(this.routeName);
}
