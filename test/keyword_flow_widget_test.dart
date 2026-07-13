// Widget-test mirror of integration_test/keyword_flow_test.dart
//
// Run with:
//   flutter test test/keyword_flow_widget_test.dart
//
// Unlike the integration_test version, this file uses testWidgets (WidgetTester)
// instead of patrolTest, so it runs on the Dart VM with no device required.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
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
import '../integration_test/mock_services.dart';

void main() {
  final sl = GetIt.instance;

  tearDown(() async {
    await sl.reset();
  });

  // ---------------------------------------------------------------------------
  // Test Case 2 – Topic Search displays publication results
  // ---------------------------------------------------------------------------
  testWidgets(
    'Test Case 2 - Topic Search displays publication results',
    (tester) async {
      final openAlex = MockOpenAlexService();
      final analytics = MockAnalyticsService();

      await tester.pumpWidget(
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
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField), 'Artificial Intelligence');
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Results are shown in the "Papers" tab (3rd tab).
      // The default tab after search is "Dashboard", so we need to switch.
      await tester.tap(find.text('Papers'));
      await tester.pumpAndSettle();

      expect(find.text('Results for "Artificial Intelligence"'), findsOneWidget);
      expect(
          find.text('Artificial Intelligence Research Paper'), findsOneWidget);
      expect(analytics.loggedEvents.contains('search_topic'), isTrue);
      expect(
        analytics.loggedParameters['search_topic']?['keyword'],
        equals('Artificial Intelligence'),
      );
    },
  );

  // ---------------------------------------------------------------------------
  // Test Case 6 – Keywords content displays keyword analytics
  // ---------------------------------------------------------------------------
  testWidgets(
    'Test Case 6 - Keywords content displays keyword analytics',
    (tester) async {
      final openAlex = MockOpenAlexService();
      final keywordViewModel = KeywordViewModel(openAlexService: openAlex);
      await keywordViewModel.loadForTopic('Artificial Intelligence');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: keywordViewModel,
          child: const MaterialApp(home: KeywordsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify keyword list visible without scrolling
      expect(find.text('Keywords'), findsOneWidget);
      expect(find.text('Topic: Artificial Intelligence'), findsOneWidget);
      expect(find.text('Most Frequent Keywords'), findsOneWidget);
      expect(find.text('Trending Keywords'), findsOneWidget);
      expect(find.text('Machine Learning'), findsWidgets);
      expect(find.text('Deep Learning'), findsWidgets);
      expect(find.text('12 publications'), findsWidgets);

      // Scroll down to reveal stats sections using drag (avoids scrollUntilVisible
      // internal .single requirement that can fail when there are no/multiple Scrollables)
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Keyword Frequency Statistics'), findsOneWidget);
      expect(find.text('12 publications'), findsWidgets);
      expect(
          find.text('60.0% of matching topic publications'), findsOneWidget);
      // All mock keywords share 2025 as peak year → multiple cards, use findsWidgets
      expect(find.text('Most active year: 2025'), findsWidgets);
      // growth = trendByYear[2025] - trendByYear[2024] = 12 - 8 = 4
      expect(find.text('Growth: +4 publications'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Keyword Trend Charts'), findsOneWidget);
    },
  );

  // ---------------------------------------------------------------------------
  // Test Case 7 – Keyword Details displays details and logs view_keyword
  // ---------------------------------------------------------------------------
  testWidgets(
    'Test Case 7 - Keyword Details displays details and logs view_keyword',
    (tester) async {
      final openAlex = MockOpenAlexService();
      final analytics = MockAnalyticsService();
      sl.registerLazySingleton<AnalyticsService>(() => analytics);

      final keywordViewModel = KeywordViewModel(openAlexService: openAlex);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: keywordViewModel,
          child: const MaterialApp(
            home: KeywordDetailScreen(
              keyword: 'Deep Learning',
              count: 10,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Keyword Details'), findsOneWidget);
      expect(find.text('Deep Learning'), findsWidgets);
      expect(find.text('Deep Learning Specific Paper'), findsOneWidget);
      expect(find.text('Deep Learning Journal'), findsOneWidget);
      expect(find.text('Deep Learning Author'), findsOneWidget);
      expect(find.text('10 publications'), findsOneWidget);
      expect(analytics.loggedEvents.contains('view_keyword'), isTrue);
      expect(
        analytics.loggedParameters['view_keyword']?['keyword'],
        equals('Deep Learning'),
      );
    },
  );
}
