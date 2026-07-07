import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../models/publication.dart';
import '../../screens/analysis_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/detail_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/search_screen.dart';
import '../../widgets/main_shell.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/search',
    redirect: (context, state) {
      final bool loggedIn = FirebaseAuth.instance.currentUser != null;
      final bool loggingIn = state.uri.toString() == '/login';

      if (!loggedIn) {
        return '/login';
      }

      if (loggingIn) {
        return '/search';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
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
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
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
