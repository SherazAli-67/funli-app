import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funli_app/src/features/main_menu/updated_feed_view/bloc_cubit/updated_feed_cubit.dart';

import 'package:get_it/get_it.dart';

import '../app_router/app_router.dart';
import '../features/main_menu/video_feed_view/bloc_cubit/video_feed_cubit.dart';
import '../features/main_menu/video_feed_view/repository/i_video_feed_repository.dart';
import '../features/main_menu/video_feed_view/repository/video_feed_repository.dart';
import '../services/deep_link_service.dart';

final getIt = GetIt.instance;

void injectionSetup() {
  getIt.registerSingleton<AppRouter>(AppRouter());

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<IVideoFeedRepository>(
    () => VideoFeedRepository(),
  );

  getIt.registerFactory<VideoFeedCubit>(
    () => VideoFeedCubit(getIt<IVideoFeedRepository>()),
  );

  getIt.registerFactory<UpdatedFeedCubit>(
        () => UpdatedFeedCubit(getIt<IVideoFeedRepository>()),
  );
  getIt.registerSingleton<DeepLinkService>(DeepLinkService());
}
