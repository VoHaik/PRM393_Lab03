import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:patrol/patrol.dart';
import 'package:provider/provider.dart';

import '../lib/screens/keyword_detail_screen.dart';
import '../lib/screens/keywords_screen.dart';
import '../lib/screens/home_screen.dart';
import '../lib/services/analytics_service.dart';
import '../lib/viewmodels/analysis_viewmodel.dart';
import '../lib/viewmodels/dashboard_viewmodel.dart';
import '../lib/viewmodels/keyword_viewmodel.dart';
import '../lib/viewmodels/search_viewmodel.dart';
import 'mock_services.dart';

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
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await $.enterText(find.byType(TextField), 'Artificial Intelligence');
      await $.tap(find.byIcon(Icons.arrow_forward_rounded));
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
    'Test Case 6 - Keywords tab content displays keyword analytics',
    ($) async {
      final openAlex = MockOpenAlexService();
      final keywordViewModel = KeywordViewModel(openAlexService: openAlex);
      await keywordViewModel.loadForTopic('Artificial Intelligence');

      await $.pumpWidgetAndSettle(
        ChangeNotifierProvider.value(
          value: keywordViewModel,
          child: const MaterialApp(home: KeywordsScreen()),
        ),
      );

      expect($('Keywords'), findsOneWidget);
      expect($('Topic: Artificial Intelligence'), findsOneWidget);
      expect($('Most Frequent Keywords'), findsOneWidget);
      expect($('Trending Keywords'), findsOneWidget);
      expect($('Machine Learning'), findsOneWidget);
      expect($('12 publications'), findsOneWidget);
    },
  );

  patrolTest(
    'Test Case 7 - Keyword Details displays details and logs view_keyword',
    ($) async {
      final openAlex = MockOpenAlexService();
      final analytics = MockAnalyticsService();
      sl.registerLazySingleton<AnalyticsService>(() => analytics);

      final keywordViewModel = KeywordViewModel(openAlexService: openAlex);

      await $.pumpWidgetAndSettle(
        ChangeNotifierProvider.value(
          value: keywordViewModel,
          child: const MaterialApp(
            home: KeywordDetailScreen(
              keyword: 'Deep Learning',
              count: 12,
            ),
          ),
        ),
      );

      expect($('Keyword Details'), findsOneWidget);
      expect($('Deep Learning'), findsWidgets);
      expect($('Deep Learning Specific Paper'), findsOneWidget);
      expect($('Deep Learning Journal'), findsOneWidget);
      expect($('Deep Learning Author'), findsOneWidget);
      expect($('12 publications'), findsOneWidget);
      expect(analytics.loggedEvents.contains('view_keyword'), isTrue);
      expect(
        analytics.loggedParameters['view_keyword']?['keyword'],
        equals('Deep Learning'),
      );
    },
  );
}
