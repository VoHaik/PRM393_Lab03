import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'utils/navigation/router.dart';
import 'utils/theme/app_theme.dart';
import 'utils/app_config.dart';
import 'injection_container.dart' as di;
import 'services/fcm_service.dart';
import 'services/remote_config_service.dart';
import 'viewmodels/analysis_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/detail_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/keyword_viewmodel.dart';
import 'viewmodels/journal_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = await AppConfig.load();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: config.firebaseOptions,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      debugPrint('Firebase already initialized natively (duplicate-app).');
    } else {
      rethrow;
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('Firebase already initialized natively (duplicate-app).');
    } else {
      rethrow;
    }
  }

  // Initialize Crashlytics: bắt toàn bộ Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Initialize dependency injection
  await di.init(config);

  // Initialize FCM: không await để tránh block màn hình splash screen
  di.sl<FcmService>().initialize().catchError((e) => debugPrint('FCM Init Error: $e'));

  // Initialize Remote Config
  di.sl<RemoteConfigService>().initialize().catchError((e) => debugPrint('Remote Config Init Error: $e'));

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => di.sl<AuthViewModel>(),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) => di.sl<SearchViewModel>(),
        ),
        ChangeNotifierProvider<DetailViewModel>(
          create: (_) => di.sl<DetailViewModel>(),
        ),
        ChangeNotifierProvider<AnalysisViewModel>(
          create: (_) => di.sl<AnalysisViewModel>(),
        ),
        ChangeNotifierProvider<DashboardViewModel>(
          create: (_) => di.sl<DashboardViewModel>(),
        ),
        ChangeNotifierProvider<KeywordViewModel>(
          create: (_) => di.sl<KeywordViewModel>(),
        ),
        ChangeNotifierProvider<JournalViewModel>(
          create: (_) => di.sl<JournalViewModel>(),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => di.sl<ProfileViewModel>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Journal Trend Analyzer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
