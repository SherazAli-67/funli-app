import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get_it/get_it.dart';

import '../app_router/app_router.dart';
import '../bloc_cubit/video_feed_cubit.dart';
import '../repository/i_video_feed_repository.dart';
import '../repository/video_feed_repository.dart';

final getIt = GetIt.instance;

void injectionSetup() {
  getIt.registerSingleton<AppRouter>(AppRouter());

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<IVideoFeedRepository>(
    () => VideoFeedRepository(getIt<FirebaseFirestore>()),
  );

  getIt.registerFactory<VideoFeedCubit>(
    () => VideoFeedCubit(getIt<IVideoFeedRepository>()),
  );
}
