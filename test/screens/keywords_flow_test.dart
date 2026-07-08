import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:journal_trend_analyzer/models/analytics_summary.dart';
import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/screens/keyword_detail_screen.dart';
import 'package:journal_trend_analyzer/screens/keywords_screen.dart';
import 'package:journal_trend_analyzer/services/analytics_service.dart';
import 'package:journal_trend_analyzer/services/openalex_service.dart';
import 'package:journal_trend_analyzer/viewmodels/analysis_viewmodel.dart';
import 'package:journal_trend_analyzer/viewmodels/search_viewmodel.dart';
import 'package:journal_trend_analyzer/widgets/main_shell.dart';

class FakeOpenAlexService extends Fake implements OpenAlexService {
  @override
  Future<List<Publication>> searchPublications(String keyword) async {
    return [
      Publication(
        id: 'W1',
        title: '$keyword Research Paper',
        publicationYear: 2024,
        citedByCount: 42,
        doiUrl: '',
        abstractText: 'A related publication.',
        authors: const [],
      ),
    ];
  }

  @override
  Future<Map<int, int>> getPublicationsTrend(String keyword) async {
    return {2022: 4, 2023: 7, 2024: 12};
  }

  @override
  Future<List<Map<String, dynamic>>> getTopKeywords(String keyword) async {
    return [
      {
        'key': 'https://openalex.org/T1',
        'key_display_name': 'Machine Learning',
        'count': 12,
      },
      {
        'key': 'https://openalex.org/T2',
        'key_display_name': 'Deep Learning',
        'count': 8,
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopAuthors(String keyword) async {
    return [
      {
        'key': 'https://openalex.org/A1',
        'key_display_name': 'Jane Researcher',
        'count': 5,
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopJournals(String keyword) async {
    return [
      {
        'key': 'https://openalex.org/S1',
        'key_display_name': 'Journal of AI',
        'count': 6,
      },
    ];
  }

  @override
  Future<AnalyticsSummary> getAnalyticsSummary(String keyword) async {
    return const AnalyticsSummary(
      totalPublications: 1,
      averageCitations: 42,
      peakYear: 2024,
    );
  }
}

class FakeAnalyticsObserver extends Fake implements FirebaseAnalyticsObserver {}

class RecordingAnalyticsService implements AnalyticsService {
  final loggedEvents = <String>[];
  final loggedParameters = <String, Map<String, dynamic>>{};

  @override
  FirebaseAnalyticsObserver getObserver() => FakeAnalyticsObserver();

  @override
  Future<void> logExportPdf(String topic) async {}

  @override
  Future<void> logLogin() async {}

  @override
  Future<void> logLogout() async {}

  @override
  Future<void> logSearchTopic(String keyword) async {
    loggedEvents.add('search_topic');
    loggedParameters['search_topic'] = {'keyword': keyword};
  }

  @override
  Future<void> logViewJournal(String journalName) async {}

  @override
  Future<void> logViewKeyword(String keyword) async {
    loggedEvents.add('view_keyword');
    loggedParameters['view_keyword'] = {'keyword': keyword};
  }

  @override
  Future<void> logViewPublication({required String title, required int year}) async {}
}

void main() {
  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('main shell exposes the Keywords tab', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/search',
          routes: [
            ShellRoute(
              builder: (context, state, child) => MainShell(child: child),
              routes: [
                GoRoute(
                  path: '/search',
                  builder: (context, state) => const SizedBox(key: Key('search')),
                ),
                GoRoute(
                  path: '/analysis',
                  builder: (context, state) => const SizedBox(key: Key('analysis')),
                ),
                GoRoute(
                  path: '/dashboard',
                  builder: (context, state) => const SizedBox(key: Key('dashboard')),
                ),
                GoRoute(
                  path: '/keywords',
                  builder: (context, state) => const SizedBox(key: Key('keywords')),
                ),
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const SizedBox(key: Key('profile')),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.text('Keywords'), findsOneWidget);
  });

  testWidgets('keywords screen lists keyword frequencies after analysis loads', (tester) async {
    final openAlexService = FakeOpenAlexService();
    final analysisViewModel = AnalysisViewModel(openAlexService: openAlexService);
    await analysisViewModel.fetchAnalysis('Artificial Intelligence');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: analysisViewModel,
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/keywords',
            routes: [
              GoRoute(
                path: '/keywords',
                builder: (context, state) => const KeywordsScreen(),
              ),
              GoRoute(
                path: '/keyword-detail',
                builder: (context, state) => const SizedBox(key: Key('detail')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Keywords'), findsOneWidget);
    expect(find.text('Topic: Artificial Intelligence'), findsOneWidget);
    expect(find.text('Machine Learning'), findsOneWidget);
    expect(find.text('12 publications'), findsOneWidget);
  });

  testWidgets('keyword detail logs view_keyword and shows selected keyword', (tester) async {
    final openAlexService = FakeOpenAlexService();
    final analyticsService = RecordingAnalyticsService();
    GetIt.instance.registerLazySingleton<AnalyticsService>(() => analyticsService);

    final analysisViewModel = AnalysisViewModel(openAlexService: openAlexService);
    await analysisViewModel.fetchAnalysis('Artificial Intelligence');

    final searchViewModel = SearchViewModel(
      openAlexService: openAlexService,
      analyticsService: analyticsService,
    );
    await searchViewModel.searchTopic('Artificial Intelligence');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: analysisViewModel),
          ChangeNotifierProvider.value(value: searchViewModel),
        ],
        child: const MaterialApp(
          home: KeywordDetailScreen(
            keyword: 'Machine Learning',
            count: 12,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Machine Learning'), findsWidgets);
    expect(find.text('12 publications'), findsOneWidget);
    expect(analyticsService.loggedEvents, contains('view_keyword'));
    expect(
      analyticsService.loggedParameters['view_keyword'],
      equals({'keyword': 'Machine Learning'}),
    );
  });
}
