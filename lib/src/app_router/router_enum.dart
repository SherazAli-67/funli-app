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

  // updatedFeedView('/updateFeed-view'),
  moodReelsView('/moodReels-view'),
  hashtagsReelsView('/hashtagReels-view'),
  filteredReelsView('/filteredReels-view'),
  remoteUserProfileView('/remoteUserProfile-view'),

  //profile pages
  profileSettingsView('/profileSettings-view'),
  profileAnalyticsView('/profileAnalyticsView'),
  updateProfileView('/updateProfile-view'),
  securityAndPrivacyView('/securityAndPrivacy-view'),
  contentPreferenceView('/contentPreference-view'),
  reportAProblemView('/reportAProblem-view'),
  helpCenterView('/helpCenter-view'),
  termsAndPrivacyView('/termsAndPrivacy-view'),

  //upload pages router setting
  createUploadReelView("/createUploadReel-view"),
  editUploadedReelView('/editUploadedReel-view'),
  publishReelView('/publishReel-view'),
  publishDraftView('/publishDraft-view'),
  videoPlayerView('/videoPlayer-view'),

  //Other pages
  reportContentView('/reportContent-view'),
  deepLinkViewer('/deepLink-view'),
  //BottomNav
  homeView('/home_view'),
  discoverView('/discover_view'),
  videoFeedView('/video_feed_view'),
  notificationView('/notification_view'),
  profileView('/profile_view');


  final String routeName;

  const RouterEnum(this.routeName);
}
