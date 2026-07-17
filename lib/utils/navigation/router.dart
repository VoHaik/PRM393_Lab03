import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/publication.dart';
import '../../screens/detail_screen.dart';
import '../../screens/keyword_detail_screen.dart';
import '../../screens/keywords_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/journals_screen.dart';
import '../../screens/journal_detail_screen.dart';
import '../../widgets/main_shell.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final bool loggedIn = context.read<AuthViewModel>().isAuthenticated;
      final bool loggingIn = state.uri.path == '/login';

      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn || state.uri.path == '/') {
        return '/home';
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
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/journals',
            builder: (context, state) => const JournalsScreen(),
          ),
          GoRoute(
            path: '/keywords',
            builder: (context, state) => const KeywordsScreen(),
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
      GoRoute(
        path: '/keyword-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return KeywordDetailScreen(
            keyword: extra['keyword']?.toString() ?? '',
            count: extra['count'] as int? ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/journal-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return JournalDetailScreen(
            journalId: extra['journalId']?.toString() ?? '',
            displayName: extra['displayName']?.toString() ?? '',
          );
        },
      ),
    ],
  );
}
