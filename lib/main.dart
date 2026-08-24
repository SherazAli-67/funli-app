import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/app_router/app_router.dart';
import 'package:funli_app/src/bloc_cubit/auth_cubit.dart';
import 'package:funli_app/src/dependancy_injection/dependency_injector.dart';
import 'package:funli_app/src/providers/discover_provider.dart';
import 'package:funli_app/src/providers/personal_info_provider.dart';
import 'package:funli_app/src/providers/profile_provider.dart';
import 'package:funli_app/src/providers/record_upload_provider.dart';
import 'package:funli_app/src/providers/size_provider.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/services/reels_cache_service.dart';
import 'package:funli_app/src/services/enhanced_video_feed_service.dart';
import 'package:provider/provider.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  injectionSetup();
  
  try {
    await EnhancedVideoFeedService().initialize();
    debugPrint('Enhanced video feed service initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize enhanced video feed service: $e');
  }

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> PersonalInfoProvider()),
        ChangeNotifierProvider(create: (_)=> RecordUploadProvider()),
        ChangeNotifierProvider(create: (_)=> SizeProvider()),
        ChangeNotifierProvider(create: (_)=> ProfileProvider()..initUserProfile()),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()..loadAll()),
      ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_)=> ReelsCacheService.cleanupMemoryCache());
    final appRouter = getIt<AppRouter>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_)=> AuthCubit()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter.router,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
          fontFamily: AppConstants.appFontFamily,
          scaffoldBackgroundColor: Colors.white
      ),
      ),
    );
  }
}
