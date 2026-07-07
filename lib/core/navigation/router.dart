import 'package:go_router/go_router.dart';
import '../../domain/entities/publication.dart';
import '../../presentation/screens/search_screen.dart';
import '../../presentation/screens/detail_screen.dart';
import '../../presentation/screens/analysis_screen.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/widgets/main_shell.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/search',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/analysis',
            builder: (context, state) {
              final keyword = state.uri.queryParameters['keyword'] ?? '';
              return AnalysisScreen(keyword: keyword);
            },
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) {
              final keyword = state.uri.queryParameters['keyword'] ?? '';
              return DashboardScreen(keyword: keyword);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final publication = state.extra as Publication;
          return DetailScreen(publication: publication);
        },
      ),
    ],
  );
}
  