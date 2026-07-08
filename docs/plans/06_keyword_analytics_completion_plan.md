# Keyword Analytics Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the Lab 03 Keywords and Keyword Detail features so they show keyword frequency, trending keywords, keyword statistics, keyword trend charts, and selected-keyword-specific detail analysis.

**Architecture:** Keep the existing Provider/GetIt/MVVM style. Add a focused keyword analytics model and view model instead of overloading `AnalysisViewModel`, because topic-level analysis and selected-keyword analysis are different data flows.

**Tech Stack:** Flutter, Dart, Provider, GetIt, Dio/OpenAlex, fl_chart, flutter_test, mocktail-compatible fakes used by current tests.

## Global Constraints

- Follow the existing app structure under `lib/models`, `lib/services`, `lib/viewmodels`, and `lib/screens`.
- Do not replace Provider/GetIt or introduce a new state management library.
- Do not add a backend service; all data must come from OpenAlex through the Flutter client.
- Keep OpenAlex requests limited to small result sets to reduce 429 risk.
- Keywords requirements come from `docs/lab03_doc/PRM393%20Lab%2003%20Firebase-Powered%20Journal%20Trend%20Analyzer.md` section 4.6 and 4.7.
- Detailed interpretation comes from `docs/lab03_doc/Keywords_va_Keyword_Detail.md`.
- Keyword Detail must analyze the selected keyword itself, not reuse the previous parent topic's trend/journal/author/publication data.
- Preserve existing search, trends, dashboard, auth, and analytics event behavior.

---

## Current Gap Summary

Already present:

- `OpenAlexService.getTopKeywords(String keyword)` groups works by `topics.id`.
- `KeywordsScreen` lists keyword names and publication counts.
- `KeywordDetailScreen` displays a selected keyword and logs `view_keyword`.
- Routes `/keywords` and `/keyword-detail` exist.

Missing or incorrect:

- `KeywordsScreen` does not show Trending keywords.
- `KeywordsScreen` does not show Keyword frequency statistics.
- `KeywordsScreen` does not show Keyword trend charts.
- `KeywordDetailScreen` reuses parent topic data from `AnalysisViewModel` and `SearchViewModel`.
- `KeywordDetailScreen` does not fetch trends, journals, publications, and authors for the selected keyword.
- Tests do not protect against the selected keyword accidentally showing parent topic data.

## File Structure

Create:

- `lib/models/keyword_analytics.dart`
  - Holds computed keyword summary data for the Keywords screen.
- `lib/models/keyword_detail.dart`
  - Holds selected-keyword-specific detail data.
- `lib/viewmodels/keyword_viewmodel.dart`
  - Loads keyword summaries for a parent topic and selected-keyword detail data.

Modify:

- `lib/services/openalex_service.dart`
  - Add keyword analytics methods using existing `/works` queries.
- `lib/injection_container.dart`
  - Register `KeywordViewModel`.
- `lib/main.dart`
  - Provide `KeywordViewModel`.
- `lib/screens/keywords_screen.dart`
  - Replace the plain list with sections for most frequent, trending, statistics, and chart preview.
- `lib/screens/keyword_detail_screen.dart`
  - Fetch and display data for the selected keyword.
- `lib/utils/navigation/router.dart`
  - Keep existing route, ensure selected keyword/count are passed safely.
- `test/screens/keywords_flow_test.dart`
  - Update fake service and widget tests for the new requirements.
- `integration_test/mock_services.dart`
  - Add deterministic keyword analytics data if integration tests use the same fake.

---

### Task 1: Add Keyword Analytics Models

**Files:**
- Create: `lib/models/keyword_analytics.dart`
- Create: `lib/models/keyword_detail.dart`
- Test: `test/screens/keywords_flow_test.dart`

**Interfaces:**
- Produces:
  - `class KeywordAnalytics`
  - `class KeywordDetailData`
  - `KeywordAnalytics.fromOpenAlexGroup(...)`
  - `int get mostActiveYear`
  - `int get latestYear`
  - `int get previousYear`
  - `int get growth`
  - `double get growthRate`

- [ ] **Step 1: Write failing model tests**

Add tests to `test/screens/keywords_flow_test.dart` or a new `test/models/keyword_analytics_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/models/keyword_analytics.dart';

void main() {
  test('keyword analytics calculates growth and most active year', () {
    final analytics = KeywordAnalytics(
      id: 'https://openalex.org/topics/T1',
      name: 'Deep Learning',
      publicationCount: 48,
      totalTopicPublications: 100,
      trendByYear: const {2023: 20, 2024: 28, 2025: 48},
    );

    expect(analytics.percentage, 48.0);
    expect(analytics.latestYear, 2025);
    expect(analytics.previousYear, 2024);
    expect(analytics.growth, 20);
    expect(analytics.growthRate, closeTo(71.43, 0.01));
    expect(analytics.mostActiveYear, 2025);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/models/keyword_analytics_test.dart
```

Expected: FAIL because `KeywordAnalytics` does not exist.

- [ ] **Step 3: Implement `KeywordAnalytics`**

Create `lib/models/keyword_analytics.dart`:

```dart
class KeywordAnalytics {
  final String id;
  final String name;
  final int publicationCount;
  final int totalTopicPublications;
  final Map<int, int> trendByYear;

  const KeywordAnalytics({
    required this.id,
    required this.name,
    required this.publicationCount,
    required this.totalTopicPublications,
    required this.trendByYear,
  });

  double get percentage {
    if (totalTopicPublications <= 0) return 0;
    return double.parse(
      ((publicationCount / totalTopicPublications) * 100).toStringAsFixed(2),
    );
  }

  int get latestYear {
    if (trendByYear.isEmpty) return 0;
    return trendByYear.keys.reduce((a, b) => a > b ? a : b);
  }

  int get previousYear {
    final sorted = trendByYear.keys.toList()..sort();
    if (sorted.length < 2) return 0;
    return sorted[sorted.length - 2];
  }

  int get growth {
    if (latestYear == 0 || previousYear == 0) return 0;
    return (trendByYear[latestYear] ?? 0) - (trendByYear[previousYear] ?? 0);
  }

  double get growthRate {
    if (previousYear == 0) return 0;
    final previous = trendByYear[previousYear] ?? 0;
    if (previous <= 0) return growth > 0 ? 100 : 0;
    return double.parse(((growth / previous) * 100).toStringAsFixed(2));
  }

  int get mostActiveYear {
    if (trendByYear.isEmpty) return 0;
    return trendByYear.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }
}
```

- [ ] **Step 4: Implement `KeywordDetailData`**

Create `lib/models/keyword_detail.dart`:

```dart
import 'publication.dart';

class KeywordDetailData {
  final String keyword;
  final Map<int, int> trendByYear;
  final List<Map<String, dynamic>> relatedJournals;
  final List<Publication> relatedPublications;
  final List<Map<String, dynamic>> topAuthors;

  const KeywordDetailData({
    required this.keyword,
    required this.trendByYear,
    required this.relatedJournals,
    required this.relatedPublications,
    required this.topAuthors,
  });
}
```

- [ ] **Step 5: Run model tests**

Run:

```bash
flutter test test/models/keyword_analytics_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/models/keyword_analytics.dart lib/models/keyword_detail.dart test/models/keyword_analytics_test.dart
git commit -m "feat: add keyword analytics models"
```

---

### Task 2: Add OpenAlex Keyword Analytics Queries

**Files:**
- Modify: `lib/services/openalex_service.dart`
- Test: `test/screens/keywords_flow_test.dart` or new service-level test if an API client fake is available

**Interfaces:**
- Consumes:
  - `KeywordAnalytics`
  - `KeywordDetailData`
- Produces:
  - `Future<int> getWorksCount(String keyword)`
  - `Future<List<KeywordAnalytics>> getKeywordAnalytics(String topic, {int limit = 5})`
  - `Future<KeywordDetailData> getKeywordDetail(String keyword)`

- [ ] **Step 1: Write failing viewmodel/service-facing fake expectations**

Update fake service in tests so later tasks can verify these calls:

```dart
class FakeOpenAlexService extends OpenAlexService {
  final List<String> detailQueries = [];

  FakeOpenAlexService() : super(apiClient: FakeApiClient());

  @override
  Future<List<KeywordAnalytics>> getKeywordAnalytics(String topic, {int limit = 5}) async {
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
        name: 'Generative AI',
        publicationCount: 10,
        totalTopicPublications: 20,
        trendByYear: {2023: 1, 2024: 3, 2025: 10},
      ),
    ];
  }

  @override
  Future<KeywordDetailData> getKeywordDetail(String keyword) async {
    detailQueries.add(keyword);
    return KeywordDetailData(
      keyword: keyword,
      trendByYear: const {2023: 2, 2024: 5, 2025: 9},
      relatedJournals: const [
        {'key_display_name': 'IEEE Access', 'count': 6},
      ],
      relatedPublications: [
        Publication(
          id: 'W-keyword',
          title: '$keyword Specific Paper',
          publicationYear: 2025,
          citedByCount: 50,
        ),
      ],
      topAuthors: const [
        {'key_display_name': 'Keyword Author', 'count': 4},
      ],
    );
  }
}
```

Expected now: FAIL because service methods and imports do not exist yet.

- [ ] **Step 2: Add imports to `openalex_service.dart`**

```dart
import '../models/keyword_analytics.dart';
import '../models/keyword_detail.dart';
```

- [ ] **Step 3: Add `getWorksCount`**

```dart
Future<int> getWorksCount(String keyword) async {
  final response = await apiClient.get(
    '/works',
    queryParameters: {
      'search': keyword,
      'per_page': 1,
    },
  );

  if (response.statusCode == 200) {
    return response.data['meta']?['count'] as int? ?? 0;
  }

  throw Exception('Failed to get works count');
}
```

- [ ] **Step 4: Add `getKeywordAnalytics`**

Implementation rule:

- Get total count for parent topic using `getWorksCount(topic)`.
- Get most frequent keywords using existing `getTopKeywords(topic)`.
- Take top `limit`.
- For each keyword display name, get trend using `getPublicationsTrend(name)`.
- Sort most frequent by OpenAlex count order.
- Trending sort will be handled in the view model/UI from `growth`.

```dart
Future<List<KeywordAnalytics>> getKeywordAnalytics(
  String topic, {
  int limit = 5,
}) async {
  final total = await getWorksCount(topic);
  final groupedKeywords = await getTopKeywords(topic);
  final validKeywords = groupedKeywords.where((item) {
    final name = item['key_display_name']?.toString().trim() ?? '';
    return name.isNotEmpty && name.toLowerCase() != 'unknown';
  }).take(limit).toList();

  final analytics = <KeywordAnalytics>[];
  for (final item in validKeywords) {
    final name = item['key_display_name']?.toString() ?? '';
    final trend = await getPublicationsTrend(name);
    analytics.add(
      KeywordAnalytics(
        id: item['key']?.toString() ?? '',
        name: name,
        publicationCount: item['count'] as int? ?? 0,
        totalTopicPublications: total,
        trendByYear: trend,
      ),
    );
  }

  return analytics;
}
```

- [ ] **Step 5: Add `getKeywordDetail`**

```dart
Future<KeywordDetailData> getKeywordDetail(String keyword) async {
  final results = await Future.wait([
    getPublicationsTrend(keyword),
    getTopJournals(keyword),
    searchPublications(keyword),
    getTopAuthors(keyword),
  ]);

  return KeywordDetailData(
    keyword: keyword,
    trendByYear: results[0] as Map<int, int>,
    relatedJournals: results[1] as List<Map<String, dynamic>>,
    relatedPublications: results[2] as List<Publication>,
    topAuthors: results[3] as List<Map<String, dynamic>>,
  );
}
```

- [ ] **Step 6: Run tests**

Run:

```bash
flutter test test/screens/keywords_flow_test.dart
```

Expected: PASS for existing tests or fail only where UI has not yet been updated in later tasks.

- [ ] **Step 7: Commit**

```bash
git add lib/services/openalex_service.dart test/screens/keywords_flow_test.dart
git commit -m "feat: add OpenAlex keyword analytics queries"
```

---

### Task 3: Add KeywordViewModel

**Files:**
- Create: `lib/viewmodels/keyword_viewmodel.dart`
- Modify: `lib/injection_container.dart`
- Modify: `lib/main.dart`
- Test: `test/screens/keywords_flow_test.dart`

**Interfaces:**
- Consumes:
  - `OpenAlexService.getKeywordAnalytics`
  - `OpenAlexService.getKeywordDetail`
- Produces:
  - `Future<void> loadForTopic(String topic)`
  - `Future<void> loadDetail(String keyword)`
  - `List<KeywordAnalytics> get mostFrequentKeywords`
  - `List<KeywordAnalytics> get trendingKeywords`
  - `KeywordDetailData? get detail`

- [ ] **Step 1: Write failing viewmodel test**

Add:

```dart
test('keyword viewmodel separates frequent and trending keywords', () async {
  final service = FakeOpenAlexService();
  final viewModel = KeywordViewModel(openAlexService: service);

  await viewModel.loadForTopic('Artificial Intelligence');

  expect(viewModel.topic, 'Artificial Intelligence');
  expect(viewModel.mostFrequentKeywords.first.name, 'Machine Learning');
  expect(viewModel.trendingKeywords.first.name, 'Generative AI');
});
```

Expected: FAIL because `KeywordViewModel` does not exist.

- [ ] **Step 2: Implement `KeywordViewModel`**

Create `lib/viewmodels/keyword_viewmodel.dart`:

```dart
import 'package:flutter/material.dart';

import '../models/keyword_analytics.dart';
import '../models/keyword_detail.dart';
import '../services/openalex_service.dart';

class KeywordViewModel extends ChangeNotifier {
  final OpenAlexService openAlexService;

  KeywordViewModel({required this.openAlexService});

  bool _isLoading = false;
  bool _isDetailLoading = false;
  String? _errorMessage;
  String _topic = '';
  List<KeywordAnalytics> _keywords = [];
  KeywordDetailData? _detail;

  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String? get errorMessage => _errorMessage;
  String get topic => _topic;
  List<KeywordAnalytics> get keywords => _keywords;
  KeywordDetailData? get detail => _detail;

  List<KeywordAnalytics> get mostFrequentKeywords => List.unmodifiable(_keywords);

  List<KeywordAnalytics> get trendingKeywords {
    final sorted = [..._keywords];
    sorted.sort((a, b) => b.growth.compareTo(a.growth));
    return sorted;
  }

  Future<void> loadForTopic(String topic) async {
    final trimmedTopic = topic.trim();
    if (trimmedTopic.isEmpty) {
      _topic = '';
      _keywords = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _topic = trimmedTopic;
    notifyListeners();

    try {
      _keywords = await openAlexService.getKeywordAnalytics(trimmedTopic);
    } catch (e) {
      _keywords = [];
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetail(String keyword) async {
    final trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) return;

    _isDetailLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _detail = await openAlexService.getKeywordDetail(trimmedKeyword);
    } catch (e) {
      _detail = null;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }
}
```

- [ ] **Step 3: Register viewmodel in DI**

Modify `lib/injection_container.dart`:

```dart
import 'viewmodels/keyword_viewmodel.dart';
```

Add with the other factories:

```dart
sl.registerFactory(() => KeywordViewModel(openAlexService: sl()));
```

- [ ] **Step 4: Provide viewmodel in `main.dart`**

Add import:

```dart
import 'viewmodels/keyword_viewmodel.dart';
```

Add provider:

```dart
ChangeNotifierProvider<KeywordViewModel>(
  create: (_) => di.sl<KeywordViewModel>(),
),
```

- [ ] **Step 5: Run test**

Run:

```bash
flutter test test/screens/keywords_flow_test.dart
```

Expected: PASS for the new viewmodel test.

- [ ] **Step 6: Commit**

```bash
git add lib/viewmodels/keyword_viewmodel.dart lib/injection_container.dart lib/main.dart test/screens/keywords_flow_test.dart
git commit -m "feat: add keyword analytics viewmodel"
```

---

### Task 4: Update Search Flow to Load Keyword Analytics

**Files:**
- Modify: `lib/screens/search_screen.dart`
- Test: `test/screens/keywords_flow_test.dart`

**Interfaces:**
- Consumes:
  - `KeywordViewModel.loadForTopic(String topic)`

- [ ] **Step 1: Write failing widget test**

Add a test that calls the search flow and expects `KeywordViewModel.topic` to be populated after search.

```dart
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

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: searchViewModel),
        ChangeNotifierProvider.value(value: analysisViewModel),
        ChangeNotifierProvider.value(value: dashboardViewModel),
        ChangeNotifierProvider.value(value: keywordViewModel),
      ],
      child: const MaterialApp(home: SearchScreen()),
    ),
  );

  await tester.enterText(
    find.byType(TextField),
    'Artificial Intelligence',
  );
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();

  expect(keywordViewModel.topic, 'Artificial Intelligence');
  expect(keywordViewModel.keywords, isNotEmpty);
});
```

Expected: FAIL because search does not call `KeywordViewModel`.

- [ ] **Step 2: Import `KeywordViewModel`**

Modify `lib/screens/search_screen.dart`:

```dart
import '../viewmodels/keyword_viewmodel.dart';
```

- [ ] **Step 3: Load keyword analytics after topic search**

In `_triggerSearch`, after the existing `AnalysisViewModel.fetchAnalysis` and before or after dashboard load:

```dart
await Future.delayed(const Duration(milliseconds: 300));
if (!mounted) return;
context.read<KeywordViewModel>().loadForTopic(trimmedKeyword);
```

Keep existing delays to reduce request bursts.

- [ ] **Step 4: Run test**

Run:

```bash
flutter test test/screens/keywords_flow_test.dart
```

Expected: PASS for search-trigger keyword loading.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/search_screen.dart test/screens/keywords_flow_test.dart
git commit -m "feat: load keyword analytics after topic search"
```

---

### Task 5: Complete Keywords Screen UI

**Files:**
- Modify: `lib/screens/keywords_screen.dart`
- Test: `test/screens/keywords_flow_test.dart`

**Interfaces:**
- Consumes:
  - `KeywordViewModel.mostFrequentKeywords`
  - `KeywordViewModel.trendingKeywords`
  - `KeywordAnalytics.percentage`
  - `KeywordAnalytics.growth`
  - `KeywordAnalytics.mostActiveYear`
  - `KeywordAnalytics.trendByYear`

- [ ] **Step 1: Write failing widget test**

Add:

```dart
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
  expect(find.text('Keyword Frequency Statistics'), findsOneWidget);
  expect(find.text('Keyword Trend Charts'), findsOneWidget);
  expect(find.textContaining('Growth'), findsWidgets);
  expect(find.textContaining('%'), findsWidgets);
});
```

Expected: FAIL because current UI only has a plain list.

- [ ] **Step 2: Replace `AnalysisViewModel` with `KeywordViewModel`**

Modify `KeywordsScreen` imports:

```dart
import '../models/keyword_analytics.dart';
import '../viewmodels/keyword_viewmodel.dart';
```

Remove direct dependency on `AnalysisViewModel`.

- [ ] **Step 3: Build section layout**

In `KeywordsScreen`, use:

```dart
Consumer<KeywordViewModel>(
  builder: (context, model, child) {
    if (model.topic.isEmpty && !model.isLoading && model.errorMessage == null) {
      return const _EmptyState(
        icon: FontAwesomeIcons.magnifyingGlassChart,
        message: 'Search for a topic first to view keyword analytics.',
      );
    }

    if (model.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryNeon),
      );
    }

    if (model.errorMessage != null) {
      return Center(
        child: Text(
          model.errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.accentRose),
        ),
      );
    }

    if (model.keywords.isEmpty) {
      return const _EmptyState(
        icon: FontAwesomeIcons.tags,
        message: 'No keyword analytics available for this topic.',
      );
    }

    return ListView(
      children: [
        _TopicChip(topic: model.topic),
        const SizedBox(height: 16),
        _SectionTitle('Most Frequent Keywords'),
        ...model.mostFrequentKeywords.map((keyword) => _KeywordCard(...)),
        const SizedBox(height: 20),
        _SectionTitle('Trending Keywords'),
        ...model.trendingKeywords.take(3).map((keyword) => _TrendingKeywordCard(...)),
        const SizedBox(height: 20),
        _SectionTitle('Keyword Frequency Statistics'),
        ...model.mostFrequentKeywords.take(3).map((keyword) => _KeywordStatsCard(keyword: keyword)),
        const SizedBox(height: 20),
        _SectionTitle('Keyword Trend Charts'),
        ...model.mostFrequentKeywords.take(3).map((keyword) => _KeywordTrendPreview(keyword: keyword)),
      ],
    );
  },
)
```

- [ ] **Step 4: Add card widgets**

Add private widgets in `keywords_screen.dart`:

```dart
class _KeywordStatsCard extends StatelessWidget {
  final KeywordAnalytics keyword;

  const _KeywordStatsCard({required this.keyword});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(keyword.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${keyword.publicationCount} publications'),
            Text('${keyword.percentage}% of matching topic publications'),
            Text('Most active year: ${keyword.mostActiveYear == 0 ? 'N/A' : keyword.mostActiveYear}'),
            Text('Growth: ${keyword.growth >= 0 ? '+' : ''}${keyword.growth} publications'),
          ],
        ),
      ),
    );
  }
}
```

For chart preview, keep it lightweight and use existing Flutter widgets if a full `fl_chart` chart is too large for the card:

```dart
class _KeywordTrendPreview extends StatelessWidget {
  final KeywordAnalytics keyword;

  const _KeywordTrendPreview({required this.keyword});

  @override
  Widget build(BuildContext context) {
    final years = keyword.trendByYear.keys.toList()..sort();
    final recentYears = years.reversed.take(5).toList().reversed.toList();
    final maxCount = keyword.trendByYear.values.isEmpty
        ? 1
        : keyword.trendByYear.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(keyword.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...recentYears.map((year) {
              final count = keyword.trendByYear[year] ?? 0;
              return Row(
                children: [
                  SizedBox(width: 48, child: Text('$year')),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: maxCount == 0 ? 0 : count / maxCount,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$count'),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run widget tests**

Run:

```bash
flutter test test/screens/keywords_flow_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/screens/keywords_screen.dart test/screens/keywords_flow_test.dart
git commit -m "feat: complete keywords analytics screen"
```

---

### Task 6: Make Keyword Detail Fetch Selected Keyword Data

**Files:**
- Modify: `lib/screens/keyword_detail_screen.dart`
- Test: `test/screens/keywords_flow_test.dart`

**Interfaces:**
- Consumes:
  - `KeywordViewModel.loadDetail(String keyword)`
  - `KeywordViewModel.detail`
  - `KeywordDetailData`

- [ ] **Step 1: Write failing widget test**

Add:

```dart
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
  expect(find.text('IEEE Access'), findsOneWidget);
  expect(find.text('Keyword Author'), findsOneWidget);
  expect(analyticsService.loggedEvents, contains('view_keyword'));
});
```

Expected: FAIL because detail does not use `KeywordViewModel`.

- [ ] **Step 2: Replace reused parent topic data**

Modify imports:

```dart
import '../viewmodels/keyword_viewmodel.dart';
```

Remove:

```dart
import '../viewmodels/analysis_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';
```

- [ ] **Step 3: Load detail in `initState`**

```dart
@override
void initState() {
  super.initState();
  di.sl<AnalyticsService>().logViewKeyword(widget.keyword);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<KeywordViewModel>().loadDetail(widget.keyword);
  });
}
```

- [ ] **Step 4: Render selected keyword detail data**

Inside `build`:

```dart
final keywordModel = context.watch<KeywordViewModel>();
final detail = keywordModel.detail;

if (keywordModel.isDetailLoading && detail == null) {
  return const Scaffold(
    body: Center(child: CircularProgressIndicator(color: AppTheme.primaryNeon)),
  );
}

if (keywordModel.errorMessage != null && detail == null) {
  return Scaffold(
    appBar: AppBar(title: const Text('Keyword Details')),
    body: Center(
      child: Text(
        keywordModel.errorMessage!,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.accentRose),
      ),
    ),
  );
}
```

Use `detail?.trendByYear ?? {}`, `detail?.relatedJournals ?? []`, `detail?.topAuthors ?? []`, and `detail?.relatedPublications ?? []` for the four sections.

- [ ] **Step 5: Related publication navigation**

For each related publication card, wrap it with:

```dart
InkWell(
  onTap: () => context.push('/detail', extra: publication),
  child: ...
)
```

Add `go_router` import if needed.

- [ ] **Step 6: Run tests**

Run:

```bash
flutter test test/screens/keywords_flow_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/screens/keyword_detail_screen.dart test/screens/keywords_flow_test.dart
git commit -m "feat: load selected keyword detail analytics"
```

---

### Task 7: Update Tests and Fakes for Full Lab 03 Keyword Requirements

**Files:**
- Modify: `test/screens/keywords_flow_test.dart`
- Modify: `integration_test/mock_services.dart`
- Modify: `integration_test/keyword_flow_test.dart` if it depends on old UI text

**Interfaces:**
- Fakes must return different data for parent topic and selected keyword.

- [ ] **Step 1: Make fake data catch the original bug**

Ensure fake service returns:

```dart
// Parent topic data
'Artificial Intelligence Research Paper'
'Machine Learning'

// Selected keyword detail data
'Deep Learning Specific Paper'
'Deep Learning Author'
'Deep Learning Journal'
```

This prevents a false pass where Keyword Detail accidentally displays parent topic data.

- [ ] **Step 2: Update integration mock service**

Add overrides:

```dart
Future<List<KeywordAnalytics>> getKeywordAnalytics(String topic, {int limit = 5}) async { ... }
Future<KeywordDetailData> getKeywordDetail(String keyword) async { ... }
```

- [ ] **Step 3: Update keyword flow integration expectations**

Expected UI should include:

```text
Most Frequent Keywords
Trending Keywords
Keyword Frequency Statistics
Keyword Trend Charts
```

Keyword detail should include selected-keyword-specific:

```text
Deep Learning Specific Paper
Deep Learning Journal
Deep Learning Author
```

- [ ] **Step 4: Run focused tests**

Run:

```bash
flutter test test/models/keyword_analytics_test.dart
flutter test test/screens/keywords_flow_test.dart
```

Expected: PASS.

- [ ] **Step 5: Run integration test if emulator/tooling is available**

Run:

```bash
patrol test --target integration_test/keyword_flow_test.dart
```

Expected: PASS. If Patrol CLI or emulator is unavailable, document the exact failure in the final report instead of changing production code to satisfy the environment.

- [ ] **Step 6: Commit**

```bash
git add test/screens/keywords_flow_test.dart integration_test/mock_services.dart integration_test/keyword_flow_test.dart
git commit -m "test: cover completed keyword analytics flow"
```

---

### Task 8: Final Verification and Documentation

**Files:**
- Modify: `docs/PROJECT_MAP.md` if it tracks completed feature status
- Create or modify: `docs/plans/06_keyword_analytics_completion_walkthrough.md`

- [ ] **Step 1: Run static analysis**

Run:

```bash
flutter analyze
```

Expected: no new errors.

- [ ] **Step 2: Run unit/widget tests**

Run:

```bash
flutter test
```

Expected: PASS. If existing unrelated deleted tests in the worktree cause failure, record the exact unrelated failure and run the focused passing commands from Task 7.

- [ ] **Step 3: Run web smoke command**

Run:

```bash
flutter run -d chrome --web-port=5000
```

Expected: app launches on `http://localhost:5000`, search works, Keywords tab shows the four required groups, Keyword Detail shows selected-keyword-specific data.

- [ ] **Step 4: Run Android build smoke command**

Run:

```bash
flutter build apk --debug
```

Expected: debug APK builds. If Gradle or environment hangs/fails, capture the exact command output.

- [ ] **Step 5: Write walkthrough**

Create `docs/plans/06_keyword_analytics_completion_walkthrough.md` with:

```markdown
# Keyword Analytics Completion Walkthrough

## Summary

Completed Lab 03 Keywords and Keyword Detail requirements.

## Implemented

- Most frequent keywords
- Trending keywords
- Keyword frequency statistics
- Keyword trend previews
- Selected-keyword-specific detail analysis
- Related journals
- Related publications
- Top contributing authors
- Author publication counts/ranking

## Verification

- `flutter analyze`: <result>
- `flutter test`: <result>
- `flutter run -d chrome --web-port=5000`: <result>
- `flutter build apk --debug`: <result>
```

- [ ] **Step 6: Commit**

```bash
git add docs/plans/06_keyword_analytics_completion_walkthrough.md docs/PROJECT_MAP.md
git commit -m "docs: document keyword analytics completion"
```

---

## Acceptance Criteria

- Keywords screen shows Most Frequent Keywords.
- Keywords screen shows Trending Keywords based on recent-year growth.
- Keywords screen shows Keyword Frequency Statistics, including publication count, percentage, growth, and most active year.
- Keywords screen shows Keyword Trend Charts or clear trend previews over recent years.
- Selecting a keyword opens Keyword Detail.
- Keyword Detail fetches data for the selected keyword.
- Keyword Detail displays publication trends over time for the selected keyword.
- Keyword Detail displays related journals for the selected keyword.
- Keyword Detail displays related publications for the selected keyword.
- Tapping a related publication opens Publication Detail.
- Keyword Detail displays top contributing authors for the selected keyword.
- Authors are ranked descending by publication count.
- `view_keyword` logs the selected keyword.
- Existing `search_topic`, Search, Trends, Dashboard, Login, and Profile flows still work.

## Self-Review

- Spec coverage: This plan maps Lab 03 section 4.6 to Tasks 1, 3, 4, and 5; section 4.7 to Tasks 2, 3, 6, and 7.
- Placeholder scan: No unresolved placeholder markers or unspecified implementation steps remain.
- Type consistency: `KeywordAnalytics`, `KeywordDetailData`, `KeywordViewModel`, `getKeywordAnalytics`, and `getKeywordDetail` are consistently named across tasks.
- Scope check: The plan only targets Keywords and Keyword Detail completion. It does not include unrelated Firebase Storage, FCM, Remote Config, Crashlytics, or Home redesign work.
