import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:patrol/patrol.dart';
import 'package:provider/provider.dart';

import '../lib/screens/journal_detail_screen.dart';
import '../lib/screens/journals_screen.dart';
import '../lib/services/analytics_service.dart';
import '../lib/viewmodels/journal_viewmodel.dart';
import '../lib/viewmodels/search_viewmodel.dart';
import 'mock_services.dart';

void main() {
  final sl = GetIt.instance;

  tearDown(() async {
    await sl.reset();
  });

  patrolTest(
    'Test Case 4 - Journals Navigation displays statistics and journal list',
    ($) async {
      final openAlex = MockOpenAlexService();
      final analytics = MockAnalyticsService();
      
      final journalViewModel = JournalViewModel(
        openAlexService: openAlex,
        analyticsService: analytics,
      );
      await journalViewModel.loadForTopic('Artificial Intelligence');

      final searchViewModel = SearchViewModel(
        openAlexService: openAlex,
        analyticsService: analytics,
      );

      await $.pumpWidgetAndSettle(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: journalViewModel),
            ChangeNotifierProvider.value(value: searchViewModel),
          ],
          child: const MaterialApp(home: JournalsScreen()),
        ),
      );

      expect($('Journals Analysis'), findsOneWidget);
      expect($('Topic: Artificial Intelligence'), findsOneWidget);
      expect($('Top Journals (Ranked by volume)'), findsOneWidget);
      expect($('Journal of AI'), findsOneWidget);
      expect($('6'), findsWidgets); // 6 papers count
    },
  );

  patrolTest(
    'Test Case 5 - Journal Details displays statistics and logs view_journal',
    ($) async {
      final openAlex = MockOpenAlexService();
      final analytics = MockAnalyticsService();
      sl.registerLazySingleton<AnalyticsService>(() => analytics);

      final journalViewModel = JournalViewModel(
        openAlexService: openAlex,
        analyticsService: analytics,
      );

      final searchViewModel = SearchViewModel(
        openAlexService: openAlex,
        analyticsService: analytics,
      );

      await $.pumpWidgetAndSettle(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: journalViewModel),
            ChangeNotifierProvider.value(value: searchViewModel),
          ],
          child: const MaterialApp(
            home: JournalDetailScreen(
              journalId: 'https://openalex.org/S1',
              displayName: 'Journal of AI',
            ),
          ),
        ),
      );

      expect($('Journal Details'), findsOneWidget);
      expect($('Mock Journal of AI'), findsOneWidget);
      expect($('Total Papers'), findsOneWidget);
      expect($('Total Citations'), findsOneWidget);
      expect($('Avg Citations'), findsOneWidget);
      expect($('Mock Related Journal Paper'), findsOneWidget);

      expect(analytics.loggedEvents.contains('view_journal'), isTrue);
      expect(
        analytics.loggedParameters['view_journal']?['journal_name'],
        equals('Mock Journal of AI'),
      );
    },
  );
}
