import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:patrol/patrol.dart';
import 'package:provider/provider.dart';

import '../lib/screens/keyword_detail_screen.dart';
import '../lib/screens/keywords_screen.dart';
import '../lib/screens/home_screen.dart';
import '../lib/services/analytics_service.dart';
import '../lib/viewmodels/analysis_viewmodel.dart';
import '../lib/viewmodels/dashboard_viewmodel.dart';
import '../lib/viewmodels/keyword_viewmodel.dart';
import '../lib/viewmodels/journal_viewmodel.dart';
import '../lib/viewmodels/search_viewmodel.dart';
import '../lib/widgets/main_shell.dart';
import 'mock_services.dart';

Widget _buildKeywordFlowApp({
  required KeywordViewModel keywordViewModel,
  String initialLocation = '/home',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Test Surface')),
            ),
          ),
          GoRoute(
            path: '/keywords',
            builder: (context, state) => const KeywordsScreen(),
          ),
        ],
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
    ],
  );

  return ChangeNotifierProvider.value(
    value: keywordViewModel,
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

void main() {
  final sl = GetIt.instance;

  tearDown(() async {
    await sl.reset();
  });

  patrolTest(
    'Test Case 2 - Topic Search displays publication results',
    ($) async {
      final openAlex = MockOpenAlexService();
      final analytics = MockAnalyticsService();

      await $.pumpWidgetAndSettle(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => SearchViewModel(
                openAlexService: openAlex,
                analyticsService: analytics,
              ),
            ),
            ChangeNotifierProvider(
              create: (_) => AnalysisViewModel(openAlexService: openAlex),
            ),
            ChangeNotifierProvider(
              create: (_) => DashboardViewModel(openAlexService: openAlex),
            ),
            ChangeNotifierProvider(
              create: (_) => KeywordViewModel(openAlexService: openAlex),
            ),
            ChangeNotifierProvider(
              create: (_) => JournalViewModel(
                openAlexService: openAlex,
                analyticsService: analytics,
              ),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await $.enterText(find.byType(TextField), 'Artificial Intelligence');
      await $.tap(find.byIcon(Icons.arrow_forward_rounded));
      await $.pump();
      await $.pump(const Duration(seconds: 2));
      await $.pumpAndSettle();

      expect($('Results for "Artificial Intelligence"'), findsOneWidget);
      expect($('Artificial Intelligence Research Paper'), findsOneWidget);
      expect(analytics.loggedEvents.contains('search_topic'), isTrue);
      expect(
        analytics.loggedParameters['search_topic']?['keyword'],
        equals('Artificial Intelligence'),
      );
    },
  );

  patrolTest(
    'Test Case 6 - Navigate to Keywords tab and display keyword analytics',
    ($) async {
      final openAlex = MockOpenAlexService();
      final keywordViewModel = KeywordViewModel(openAlexService: openAlex);
      await keywordViewModel.loadForTopic('Artificial Intelligence');

      await $.pumpWidgetAndSettle(
        _buildKeywordFlowApp(keywordViewModel: keywordViewModel),
      );

      expect($('Home Test Surface'), findsOneWidget);

      await $.tap($('Keywords'));
      await $.pumpAndSettle();

      expect($('Keywords'), findsWidgets);
      expect($('Topic: Artificial Intelligence'), findsOneWidget);
      expect($('Most Frequent Keywords'), findsOneWidget);
      expect($('Trending Keywords'), findsOneWidget);
      expect($('Machine Learning'), findsWidgets);
      expect($('Deep Learning'), findsWidgets);

      await $.scrollUntilVisible(
        finder: $('Keyword Frequency Statistics'),
        view: find.byType(Scrollable),
        delta: const Offset(0, -300),
      );
      expect($('Keyword Frequency Statistics'), findsOneWidget);

      await $.scrollUntilVisible(
        finder: $('Keyword Trend Charts'),
        view: find.byType(Scrollable),
        delta: const Offset(0, -300),
      );
      expect($('Keyword Trend Charts'), findsOneWidget);
    },
  );

  patrolTest(
    'Test Case 7 - Open keyword from list and display keyword analysis',
    ($) async {
      final openAlex = MockOpenAlexService();
      final analytics = MockAnalyticsService();
      sl.registerLazySingleton<AnalyticsService>(() => analytics);

      final keywordViewModel = KeywordViewModel(openAlexService: openAlex);
      await keywordViewModel.loadForTopic('Artificial Intelligence');

      await $.pumpWidgetAndSettle(
        _buildKeywordFlowApp(
          keywordViewModel: keywordViewModel,
          initialLocation: '/keywords',
        ),
      );

      expect($('Keywords'), findsWidgets);
      expect($('Deep Learning'), findsWidgets);

      await $.tester.tap(find.text('Deep Learning').first);
      await $.pumpAndSettle();

      expect($('Keyword Details'), findsOneWidget);
      expect($('Deep Learning'), findsWidgets);
      expect($('Deep Learning Specific Paper'), findsOneWidget);
      expect($('Deep Learning Journal'), findsOneWidget);
      expect($('Deep Learning Author'), findsOneWidget);
      expect($('10 publications'), findsOneWidget);
      expect(analytics.loggedEvents.contains('view_keyword'), isTrue);
      expect(
        analytics.loggedParameters['view_keyword']?['keyword'],
        equals('Deep Learning'),
      );
    },
  );

}
