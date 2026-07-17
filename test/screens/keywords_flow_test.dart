import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:journal_trend_analyzer/models/analytics_summary.dart';
import 'package:journal_trend_analyzer/models/keyword_analytics.dart';
import 'package:journal_trend_analyzer/models/keyword_detail.dart';
import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/screens/keyword_detail_screen.dart';
import 'package:journal_trend_analyzer/screens/keywords_screen.dart';
import 'package:journal_trend_analyzer/screens/home_screen.dart';
import 'package:journal_trend_analyzer/services/analytics_service.dart';
import 'package:journal_trend_analyzer/services/openalex_service.dart';
import 'package:journal_trend_analyzer/viewmodels/analysis_viewmodel.dart';
import 'package:journal_trend_analyzer/viewmodels/dashboard_viewmodel.dart';
import 'package:journal_trend_analyzer/viewmodels/keyword_viewmodel.dart';
import 'package:journal_trend_analyzer/viewmodels/search_viewmodel.dart';
import 'package:journal_trend_analyzer/viewmodels/journal_viewmodel.dart';
import 'package:journal_trend_analyzer/widgets/main_shell.dart';

class FakeOpenAlexService extends Fake implements OpenAlexService {
  final List<String> detailQueries = [];

  @override
  Future<int> getWorksCount(String keyword) async {
    return 20;
  }

  @override
  Future<List<KeywordAnalytics>> getKeywordAnalytics(
    String topic, {
    int limit = 5,
  }) async {
    return [
      const KeywordAnalytics(
        id: 'https://openalex.org/topics/T1',
        name: 'Machine Learning',
        publicationCount: 12,
        totalTopicPublications: 20,
        trendByYear: {2023: 4, 2024: 8, 2025: 12},
      ),
      const KeywordAnalytics(
        id: 'https://openalex.org/topics/T2',
        name: 'Deep Learning',
        publicationCount: 10,
        totalTopicPublications: 20,
        trendByYear: {2023: 1, 2024: 3, 2025: 10},
      ),
      const KeywordAnalytics(
        id: 'https://openalex.org/topics/T3',
        name: 'Neural Networks',
        publicationCount: 8,
        totalTopicPublications: 20,
        trendByYear: {2023: 3, 2024: 4, 2025: 5},
      ),
    ].take(limit).toList();
  }

  @override
  Future<KeywordDetailData> getKeywordDetail(String keyword) async {
    detailQueries.add(keyword);
    return KeywordDetailData(
      keyword: keyword,
      trendByYear: const {2023: 2, 2024: 5, 2025: 9},
      relatedJournals: const [
        {
          'key': 'https://openalex.org/S-keyword',
          'key_display_name': 'Deep Learning Journal',
          'count': 6,
        },
      ],
      relatedPublications: [
        Publication(
          id: 'W-keyword',
          title: '$keyword Specific Paper',
          publicationYear: 2025,
          citedByCount: 50,
          doiUrl: '',
          abstractText: 'A keyword-specific publication.',
          authors: const [],
        ),
      ],
      topAuthors: const [
        {
          'key': 'https://openalex.org/A-keyword',
          'key_display_name': 'Deep Learning Author',
          'count': 4,
        },
      ],
    );
  }

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
    if (keyword == 'Machine Learning') {
      return {2023: 4, 2024: 8, 2025: 12};
    }
    if (keyword == 'Deep Learning') {
      return {2023: 1, 2024: 3, 2025: 10};
    }
    if (keyword == 'Neural Networks') {
      return {2023: 3, 2024: 4, 2025: 5};
    }
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

class FailingKeywordDetailOpenAlexService extends FakeOpenAlexService {
  @override
  Future<KeywordDetailData> getKeywordDetail(String keyword) async {
    throw Exception('keyword detail failed');
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

  test('keyword viewmodel separates frequent and trending keywords', () async {
    final service = FakeOpenAlexService();
    final viewModel = KeywordViewModel(openAlexService: service);

    await viewModel.loadForTopic('Artificial Intelligence');

    expect(viewModel.topic, 'Artificial Intelligence');
    expect(viewModel.mostFrequentKeywords.first.name, 'Machine Learning');
    expect(viewModel.trendingKeywords.first.name, 'Deep Learning');
  });

  test('keyword detail failure does not replace topic keyword state', () async {
    final service = FailingKeywordDetailOpenAlexService();
    final viewModel = KeywordViewModel(openAlexService: service);

    await viewModel.loadForTopic('Artificial Intelligence');
    await viewModel.loadDetail('Deep Learning');

    expect(viewModel.errorMessage, isNull);
    expect(viewModel.detailErrorMessage, contains('keyword detail failed'));
    expect(viewModel.topic, 'Artificial Intelligence');
    expect(viewModel.keywords, isNotEmpty);
  });

  testWidgets('main shell exposes the Keywords tab', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/home',
          routes: [
            ShellRoute(
              builder: (context, state, child) => MainShell(child: child),
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const SizedBox(key: Key('home')),
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

  testWidgets('search loads keyword analytics for searched topic', (tester) async {
    final service = FakeOpenAlexService();
    final analytics = RecordingAnalyticsService();
    final searchViewModel = SearchViewModel(
      openAlexService: service,
      analyticsService: analytics,
    );
    final analysisViewModel = AnalysisViewModel(openAlexService: service);
    final dashboardViewModel = DashboardViewModel(openAlexService: service);
    final keywordViewModel = KeywordViewModel(openAlexService: service);
    final journalViewModel = JournalViewModel(openAlexService: service, analyticsService: analytics);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: searchViewModel),
          ChangeNotifierProvider.value(value: analysisViewModel),
          ChangeNotifierProvider.value(value: dashboardViewModel),
          ChangeNotifierProvider.value(value: keywordViewModel),
          ChangeNotifierProvider.value(value: journalViewModel),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Artificial Intelligence');
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(keywordViewModel.topic, 'Artificial Intelligence');
    expect(keywordViewModel.keywords, isNotEmpty);
  });

  testWidgets('keywords screen shows required analytics sections', (tester) async {
    final keywordViewModel = KeywordViewModel(openAlexService: FakeOpenAlexService());
    await keywordViewModel.loadForTopic('Artificial Intelligence');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: keywordViewModel,
        child: const MaterialApp(home: KeywordsScreen()),
      ),
    );

    expect(find.text('Most Frequent Keywords'), findsOneWidget);
    expect(find.text('Trending Keywords'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Keyword Frequency Statistics'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Keyword Frequency Statistics'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Keyword Trend Charts'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Keyword Trend Charts'), findsOneWidget);
    expect(find.textContaining('Growth'), findsWidgets);
    expect(find.textContaining('%'), findsWidgets);
  });

  testWidgets('keyword detail fetches data for selected keyword', (tester) async {
    final service = FakeOpenAlexService();
    final analyticsService = RecordingAnalyticsService();
    GetIt.instance.registerLazySingleton<AnalyticsService>(() => analyticsService);

    final keywordViewModel = KeywordViewModel(openAlexService: service);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: keywordViewModel,
        child: const MaterialApp(
          home: KeywordDetailScreen(
            keyword: 'Deep Learning',
            count: 48,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(service.detailQueries, contains('Deep Learning'));
    expect(find.text('Deep Learning Specific Paper'), findsOneWidget);
    expect(find.text('Deep Learning Journal'), findsOneWidget);
    expect(find.text('Deep Learning Author'), findsOneWidget);
    expect(analyticsService.loggedEvents, contains('view_keyword'));
  });
}
