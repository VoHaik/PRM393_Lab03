import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/navigation/router.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;
import 'presentation/bloc/analysis/analysis_bloc.dart';
import 'presentation/bloc/dashboard/dashboard_bloc.dart';
import 'presentation/bloc/detail/detail_bloc.dart';
import 'presentation/bloc/search/search_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchBloc>(
          create: (_) => di.sl<SearchBloc>(),
        ),
        BlocProvider<DetailBloc>(
          create: (_) => di.sl<DetailBloc>(),
        ),
        BlocProvider<AnalysisBloc>(
          create: (_) => di.sl<AnalysisBloc>(),
        ),
        BlocProvider<DashboardBloc>(
          create: (_) => di.sl<DashboardBloc>(),
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
