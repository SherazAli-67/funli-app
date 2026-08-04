# FUNLI — Project Overview

**FUNLI** (`funli_app`) is a mood-based short-video ("reels") social mobile app built with **Flutter** and backed entirely by **Firebase**. Users pick their current mood, get a vertical TikTok-style feed of videos ("feels") matching that mood, and can record, edit, and publish their own mood-tagged reels.

- **Framework:** Flutter (Dart SDK ^3.10.7), version `1.0.0+1`
- **Backend:** Firebase (Auth, Cloud Firestore, Storage, Cloud Messaging, Dynamic Links)
- **Platforms:** Android and iOS are fully configured (app id `com.sherazapps.moodstream`); web/macOS/linux/windows folders exist but are unconfigured templates
- **Font/branding:** Montserrat, deep-purple seed color, custom SVG icon set

---

## Core Concept: The Mood System

The app revolves around **19 moods** (defined in `lib/src/app_data.dart`), each with an emoji: Happy, Excitement, Love, Confident, Pride, Care, Curious, Neutral, Confused, Bored, Sad, Crying, Fear, Angry, Disgust, Anxiety, Contempt, Embarrassment, Surprise.

- Users select their mood via a **circular emoji scroll wheel** (`MoodSelectingScrollWheelWidget`), which persists to the `mood` field on their user document.
- Every reel carries a `moodTag` chosen at upload time. Publishing indexes the reel into `moods/{mood}/reels` for fast mood-based queries.
- The home feed filters reels by the user's current mood. (Note: `ReelsService.fetchReels` currently remaps mood "Sad" to "Happy".)
- Camera-based facial emotion detection (Google ML Kit face detection) was scaffolded in `lib/src/features/mood_detection_setup/` but is **entirely commented out** — mood selection is manual for now.
- The Discover page surfaces trending moods and the analytics dashboard computes mood percentages and streaks from the user's own posts.

---

## Feature Breakdown (`lib/src/features/`)

### Onboarding & Authentication
- **`welcome_page.dart`** — Landing screen with an auto-playing carousel of three onboarding slides, plus buttons for email login/signup and Google sign-in.
- **`authentication/`** — `LoginPage`, `SignupPage`, `ForgetPasswordPage`, `ResetPasswordPage`. Supports email/password and Google sign-in (popup on web, `google_sign_in` on mobile). Signup creates a `users/{uid}` Firestore document.
- **`personalization/`** — Post-signup flow: date-of-birth + gender pickers, then interest selection (20 emoji-labeled interests).

### Main Menu (4 bottom-nav tabs, wrapped in a GoRouter `ShellRoute`)
1. **`video_feed_view/`** — The home feed: vertical `PreloadPageView` of mood-filtered reels with Firestore pagination, pull-to-refresh, and background refresh timers. Includes the full **comments system** (comment bottom sheet with replies, likes on comments/replies, pinned comments, emoji picker).
2. **`discover_page/`** — Trending hashtags and trending moods (rows of reel previews per mood), plus a filter bottom sheet (`ReelFilter`: mood, popularity, location, language) opening `FilteredReelsPage`.
3. **`notifications/`** — In-app notification list (like / comment / reply / follow / mention / reelView / system types) from the user's `notifications` subcollection.
4. **`profile/`** — Own profile with reels, bookmarks, and drafts tabs; `EditProfilePage`; and `RemoteUserProfilePage` for other users with follow/unfollow and private-account handling.

### Reels Viewing
- **`reels_page/`** — `UpdatedReelsPage`, a universal reels viewer opened from profile, hashtag, mood, bookmark, search, or deep-link contexts. Has its own `ReelsCubit` + repository handling pagination and preloading of the next 2 videos.
- **`mood_reels_page/`** — Grid of reels for a single mood ("&lt;Mood&gt; Feels").
- **`hashtagged_reels_page/`** — Reels grid per hashtag, with follow/unfollow-hashtag support.

### Creating Content ("Feels")
- **`upload_feel/`** — The record/upload pipeline:
  1. `CreateUploadFeelPage` — in-app camera recording (`camera` package: zoom, flip, timed recording) or pick a video with `file_picker`; mood selection via the scroll wheel.
  2. `EditUploadedFeelPage` — trimming/editing with `video_trimmer`.
  3. `PublishReelPage` — caption with hashtag/mention autocomplete, visibility, publish or save-to-draft.
  4. `PublishDraftPage` — publish a previously saved draft.
- Publishing compresses the video (`video_compress`), generates a thumbnail, uploads both to Firebase Storage with progress, then writes the reel document plus hashtag/mood/user index entries.

### Other Features
- **`profile_analytics_dashboard/`** — Creator analytics: view charts (`fl_chart`), mood history, mood percentages and streaks, follower stats.
- **`search_page.dart`** — Three-tab search (Feels / Users / Hashtags) with debounced, paginated prefix queries.
- **`settings/`** — Settings hub: privacy & security (account visibility: public / followers-of-followers / followers-only, suggest-account, remember-me), content preferences (adult content toggle), report a problem, help center (FAQs + contact channels), terms & privacy.
- **`report_content/`** — Report a reel with canned reasons.
- **`deep_link_handler.dart`** — Resolves a reel ID from a deep link and opens it in the reels viewer.

---

## Architecture

### State Management (Hybrid)
- **flutter_bloc (Cubits):** `AuthCubit` (all auth flows + Firebase error-code → message mapping) and `ReelsCubit` (reels-page pagination/preloading).
- **Provider (12 ChangeNotifiers, registered in `main.dart`):**

| Provider | Responsibility |
|---|---|
| `PersonalInfoProvider` | Onboarding selections (gender, DOB, interests) |
| `MainMenuTabChangeProvider` | Bottom-nav tab index |
| `RecordUploadProvider` | Recording state, mood tag, playback speed, mute; drives `publishReel()` |
| `ReelProvider` | Current feed reel state (mute, like helpers) |
| `SizeProvider` | Cached screen size |
| `ProfileProvider` | Current user profile editing + profile tab index |
| `MoodReelsProvider` | Paginated reels for a mood |
| `FeelsSearchProvider` / `UsersSearchProvider` / `HashtagSearchProvider` | Paginated search results per tab |
| `DiscoverProvider` | Trending hashtags + moods with cache refresh |
| `ReportContentProvider` | Report reason selection/submission |

### Routing (`lib/src/app_router/`)
GoRouter (registered in get_it) with initial location `/welcome_view` and an **auth redirect guard** (unauthenticated → public routes only; authenticated users are pushed to `/video_feed_view`). A `ShellRoute` hosts the 4 tab routes (`/video_feed_view`, `/notification_view`, `/discover_view`, `/profile_view`); ~20 more top-level routes cover auth, personalization, search, reels viewers, profiles, settings, the upload flow (`/createUploadReel-view` on the root navigator, full-screen), analytics, reporting, and deep links. Arguments are passed via `state.extra` maps.

### Dependency Injection (`lib/src/dependancy_injection/`)
Lightweight get_it setup: `AppRouter` (singleton), `FirebaseFirestore.instance` (lazy singleton), `DeepLinkService` (singleton).

### Services (`lib/src/services/` — 17 services)
Singleton/static service classes handle all backend work:

- **`auth_service.dart`** — Email signup/sign-in, user info updates.
- **`reels_service.dart`** — Fetch reels by mood/user/bookmark/hashtag, pagination, likes (reels, comments, replies), views, bookmarks, shares.
- **`comment_service.dart`** — Comments, replies, pinning.
- **`enhanced_video_feed_service.dart`** (~900 lines) — The video engine: `VideoPlayerController` pooling with LRU eviction + reference counting, priority download queue, network-speed detection, background isolate processing, audio-session management (only one video plays audio at a time), performance metrics.
- **`reels_cache_service.dart`** (~1,100 lines) — Multi-level caching: in-memory map + three `flutter_cache_manager` disk caches (general / priority / current-mood) + SharedPreferences JSON caches for reels, user reels, bookmarks, drafts.
- **`reels_data_sources.dart`** + **`universal_reel_feed_controller.dart`** — A `ReelDataSource` abstraction (mood / hashtag / user / bookmark / general sources) wrapped by a universal feed controller with stream-based pagination, powering `UpdatedReelsPage`.
- **`publish_reel_service.dart`** — Storage uploads with progress, reel document creation, hashtag/mood/user indexing, drafts.
- **`user_service.dart`** — Profiles, follow/unfollow (with private-account approval and notifications), follower counts, mood updates, profile picture upload.
- **`search_service.dart`** — Firestore prefix-range queries on reels, users, and hashtags.
- **`settings_service.dart`** — Account visibility, content flags, problem reports, mood analytics computation.
- **`hashtag_service.dart`**, **`mood_service.dart`**, **`hashtag_mood_cached_reels.dart`**, **`mood_analytics_cache_service.dart`** — Hashtag/mood queries and their SharedPreferences caches.
- **`notifications_service.dart`** — In-app notification documents and unread counts.
- **`deep_link_service.dart`** — Listens to `uni_links` + Firebase Dynamic Links; handles the `funliapp://` scheme and `funli-web.vercel.app` host, routing `/reels/{id}` into the app; generates short share links via `funliapp.page.link`.

### Models (`lib/src/models/`)
`ReelModel` (video URL, thumbnail, caption, hashtags, mentions, moodTag, visibility, counts, reports), `UserModel` (username, email, DOB, current mood, interests, bio, profile picture, gender, `ProfileVisibility` enum), `AddCommentModel`, `LikeModel`, `FollowModel` (with `isApproved` for private accounts), `ShareReelModel`, `HashtagModel`, `MoodModel`, `NotificationModel`, `ReelFilter`, `ReportContentModel`, `OnboardingModel`.

---

## Firebase Data Model

**Products used:** Auth (email/password + Google), Cloud Firestore, Storage, Cloud Messaging (FCM), Dynamic Links.

**Firestore collections:**
- Top-level: `users`, `reels`, `hashtags`, `moods`, `problemsReported`, `reportedContent`
- `reels/{id}/` → `likes`, `comments` (→ `replies`, each with own `likes`), `shares`, `views`
- `users/{uid}/` → `likes`, `bookmarks`, `drafts`, `reels`, `followers`, `following`, `followingHashtags`, `notifications`
- `hashtags/{tag}/` → `reels`, `followers`
- `moods/{mood}/` → `reels`

**Storage paths:** `reels/{uid}/{reelID}/video.mp4` + `thumbnail.jpg`, `profiles/{uid}/profilePicture.jpg`

**Push notifications:** `FirebaseNotificationsService` requests permissions, saves the FCM token to the user doc, and shows foreground/background messages via `flutter_local_notifications` (channel `funli-notification`).

---

## Video Performance System

Documented in `ENHANCED_VIDEO_PERFORMANCE.md`, the app implements a "TikTok-level" playback pipeline:
- Maximum 8 video controllers in memory with LRU eviction
- Network-aware prefetching (5 videos ahead on fast Wi-Fi, 1 on slow mobile data)
- Priority download queue (current video → next 1–2 → previous → background)
- Multi-level cache: memory → disk → network, with mood-based priority
- Audio-session management to prevent overlapping audio between videos
- Built-in performance metrics (load times, buffer events, cache hit rate) with debug overlays

---

## Supporting Code

- **`lib/src/widgets/`** — ~35 shared widgets: `EnhancedVideoFeedItem` (the optimized player cell), post action buttons (like/comment/share/bookmark), like animation, the mood scroll wheel, profile widgets, gradient buttons/text, text fields, reel grid items, DOB/gender selectors.
- **`lib/src/helpers/`** — Count formatting, hashtag/mention extraction from captions, snackbar wrappers, "time ago" formatting.
- **`lib/src/res/`** — Colors, gradients, text styles, icon paths, Firestore collection-name constants, spacing, app constants.
- **`lib/src/loading_shimmers/`** — Shimmer placeholders for feeds, grids, notifications, trending sections.
- **`lib/src/testing/social_media/`** — Not tests: an experimental social text-editing module (mock suggestion API, custom text controller/fields) powering hashtag/mention autocomplete in captions.
- **`lib/src/app_data.dart`** — Static data: 19 moods with emojis, 20 interests, FAQs, contact channels, report reasons, sample fallback reels.
- **`packages/circle_wheel_scroll/`** — Locally **vendored copy** of the unmaintained pub.dev `circle_wheel_scroll` package (0.0.3), patched to compile on newer Flutter. Provides the circular list scroll view used by the mood-picker wheel.

**Assets:** ~65 SVG/PNG icons (navigation, auth, moods, social, onboarding, contact-us), a Lottie success animation, Montserrat font (Regular/Medium/Bold), and a native splash screen via `flutter_native_splash`.

---

## Key Dependencies

| Category | Packages |
|---|---|
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`, `firebase_dynamic_links` |
| State / DI / Routing | `flutter_bloc`, `provider`, `get_it`, `go_router`, `equatable` |
| Video | `video_player`, `camera`, `video_compress`, `video_trimmer`, `preload_page_view`, `flutter_cache_manager` |
| UI | `flutter_svg`, `carousel_slider`, `shimmer`, `lottie`, `cached_network_image`, `like_button`, `fl_chart`, `emoji_picker_flutter`, `circle_wheel_scroll` (vendored) |
| Platform / misc | `google_sign_in`, `image_picker`, `file_picker`, `permission_handler`, `shared_preferences`, `share_plus`, `uni_links`, `connectivity_plus`, `flutter_local_notifications`, `fluttertoast` |

---

## Platform Configuration

- **Android** — id `com.sherazapps.moodstream`, label "FUNLI", minSdk 23, versionCode 20, core library desugaring. Permissions: camera, microphone, storage, internet, post-notifications, boot-completed. Deep-link intent filters for `https://funli-web.vercel.app/reels`, `https://funliapp.page.link`, and `funliapp://`. Release build currently still signs with debug keys (marked TODO).
- **iOS** — bundle id `com.sherazapps.moodstream`; camera/microphone/photo-library usage descriptions; URL schemes for Google sign-in and `funliapp`.
- Known inconsistency: the Dynamic Links code references package `com.funtech.funli`, while the actual app ids are `com.sherazapps.moodstream`.

---

## Current State & Notable Observations

- **Testing:** effectively none — `test/widget_test.dart` is the stale default Flutter counter test.
- **Architecture style:** pragmatic rather than strictly layered — singleton services with static methods plus a Provider/Cubit mix; get_it is only lightly used.
- **Data access pattern:** mood/hashtag/user reel indexes store reel IDs in subcollections, resolved with per-document reads against `reels` (N+1 reads per page).
- **In progress (uncommitted):** Firebase configuration is being switched (`firebase.json` and `lib/firebase_options.dart` deleted; `google-services.json` / `GoogleService-Info.plist` modified — `Firebase.initializeApp()` now relies on platform config files), edits to the signup page and auth service, and the newly vendored `circle_wheel_scroll` package.
- **Dormant features:** ML Kit camera-based emotion detection and `DevicePreview` are scaffolded but commented out.
