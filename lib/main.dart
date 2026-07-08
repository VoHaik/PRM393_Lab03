import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/navigation/router.dart';
import 'utils/theme/app_theme.dart';
import 'utils/app_config.dart';
import 'injection_container.dart' as di;
import 'viewmodels/analysis_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/detail_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/keyword_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = await AppConfig.load();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: config.firebaseOptions,
  );

  // Initialize dependency injection
  await di.init(config);

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
