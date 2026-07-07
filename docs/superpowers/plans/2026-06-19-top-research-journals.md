# Top Research Journals Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fully implement lab requirement 4.5 by showing the top research journals for the selected topic as a ranked chart/list in the Trend Analysis screen.

**Architecture:** Reuse the existing OpenAlex `group_by=primary_location.source.id` data source and repository method. Add a `GetTopJournals` use case, wire it through dependency injection and `AnalysisBloc`, then replace the non-required Top Keywords slide with a Top Journals slide that displays the top five journals and publication counts.

**Tech Stack:** Flutter, Dart, flutter_bloc, equatable, fl_chart-style custom chart widgets, flutter_test.

---

## File Structure

- Create: `lib/domain/usecases/get_top_journals.dart`
  - Mirrors `GetTopKeywords` and `GetTopAuthors`.
  - Calls `PublicationRepository.getTopJournals(keyword)`.

- Modify: `lib/injection_container.dart`
  - Imports and registers `GetTopJournals`.
  - Injects `getTopJournals` into `AnalysisBloc`.

- Modify: `lib/presentation/bloc/analysis/analysis_bloc.dart`
  - Adds a `GetTopJournals` dependency.
  - Fetches journals with the existing trend/authors analysis requests.
  - Emits top journals in `AnalysisSuccess`.

- Modify: `lib/presentation/bloc/analysis/analysis_state.dart`
  - Adds `topJournals` to `AnalysisSuccess`.
  - Includes `topJournals` in `props`.

- Modify: `lib/presentation/screens/analysis_screen.dart`
  - Replaces the Top Keywords carousel slide with Top Journals.
  - Displays a ranked top-five journal list/chart with publication counts.

- Create: `test/presentation/bloc/analysis/analysis_bloc_test.dart`
  - Verifies `AnalysisBloc` emits `AnalysisSuccess` with top journal data.

- Create: `test/domain/usecases/get_top_journals_test.dart`
  - Verifies the use case delegates to `PublicationRepository.getTopJournals`.

---

### Task 1: Add `GetTopJournals` Use Case

**Files:**
- Create: `lib/domain/usecases/get_top_journals.dart`
- Test: `test/domain/usecases/get_top_journals_test.dart`

- [ ] **Step 1: Write the failing use case test**

Create `test/domain/usecases/get_top_journals_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/domain/entities/analytics_summary.dart';
import 'package:journal_trend_analyzer/domain/entities/publication.dart';
import 'package:journal_trend_analyzer/domain/repositories/publication_repository.dart';
import 'package:journal_trend_analyzer/domain/usecases/get_top_journals.dart';

class FakePublicationRepository implements PublicationRepository {
  String? receivedKeyword;

  @override
  Future<List<Map<String, dynamic>>> getTopJournals(String keyword) async {
    receivedKeyword = keyword;
    return [
      {
        'key': 'https://openalex.org/S123',
        'key_display_name': 'Journal of Machine Learning Research',
        'count': 42,
      },
    ];
  }

  @override
  Future<AnalyticsSummary> getAnalyticsSummary(String keyword) {
    throw UnimplementedError();
  }

  @override
  Future<Publication> getPublicationById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Map<int, int>> getPublicationsTrend(String keyword) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getTopAuthors(String keyword) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getTopKeywords(String keyword) {
    throw UnimplementedError();
  }

  @override
  Future<List<Publication>> searchPublications(String keyword) {
    throw UnimplementedError();
  }
}

void main() {
  test('delegates top journal aggregation to repository', () async {
    final repository = FakePublicationRepository();
    final useCase = GetTopJournals(repository);

    final result = await useCase('artificial intelligence');

    expect(repository.receivedKeyword, 'artificial intelligence');
    expect(result, hasLength(1));
    expect(result.first['key_display_name'], 'Journal of Machine Learning Research');
    expect(result.first['count'], 42);
  });
}
```

- [ ] **Step 2: Run the test and verify it fails**

Run:

```powershell
flutter test test/domain/usecases/get_top_journals_test.dart
```

Expected: FAIL because `lib/domain/usecases/get_top_journals.dart` does not exist.

- [ ] **Step 3: Implement the use case**

Create `lib/domain/usecases/get_top_journals.dart`:

```dart
import '../repositories/publication_repository.dart';

class GetTopJournals {
  final PublicationRepository repository;

  GetTopJournals(this.repository);

  Future<List<Map<String, dynamic>>> call(String keyword) {
    return repository.getTopJournals(keyword);
  }
}
```

- [ ] **Step 4: Run the test and verify it passes**

Run:

```powershell
flutter test test/domain/usecases/get_top_journals_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```powershell
git add lib/domain/usecases/get_top_journals.dart test/domain/usecases/get_top_journals_test.dart
git commit -m "feat: add top journals use case"
```

---

### Task 2: Wire Top Journals Through `AnalysisBloc`

**Files:**
- Modify: `lib/presentation/bloc/analysis/analysis_state.dart`
- Modify: `lib/presentation/bloc/analysis/analysis_bloc.dart`
- Modify: `lib/injection_container.dart`
- Test: `test/presentation/bloc/analysis/analysis_bloc_test.dart`

- [ ] **Step 1: Write the failing BLoC test**

Create `test/presentation/bloc/analysis/analysis_bloc_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/domain/entities/analytics_summary.dart';
import 'package:journal_trend_analyzer/domain/entities/publication.dart';
import 'package:journal_trend_analyzer/domain/repositories/publication_repository.dart';
import 'package:journal_trend_analyzer/domain/usecases/get_publications_trend.dart';
import 'package:journal_trend_analyzer/domain/usecases/get_top_authors.dart';
import 'package:journal_trend_analyzer/domain/usecases/get_top_journals.dart';
import 'package:journal_trend_analyzer/domain/usecases/get_top_keywords.dart';
import 'package:journal_trend_analyzer/presentation/bloc/analysis/analysis_bloc.dart';
import 'package:journal_trend_analyzer/presentation/bloc/analysis/analysis_event.dart';
import 'package:journal_trend_analyzer/presentation/bloc/analysis/analysis_state.dart';

class FakePublicationRepository implements PublicationRepository {
  @override
  Future<Map<int, int>> getPublicationsTrend(String keyword) async {
    return {2024: 10, 2025: 15};
  }

  @override
  Future<List<Map<String, dynamic>>> getTopJournals(String keyword) async {
    return [
      {
        'key': 'https://openalex.org/S123',
        'key_display_name': 'Journal of Machine Learning Research',
        'count': 42,
      },
      {
        'key': 'https://openalex.org/S456',
        'key_display_name': 'Nature Machine Intelligence',
        'count': 30,
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopAuthors(String keyword) async {
    return [
      {
        'key': 'https://openalex.org/A123',
        'key_display_name': 'Jane Researcher',
        'count': 8,
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopKeywords(String keyword) async {
    return [
      {
        'key': 'https://openalex.org/T123',
        'key_display_name': 'Artificial intelligence',
        'count': 20,
      },
    ];
  }

  @override
  Future<AnalyticsSummary> getAnalyticsSummary(String keyword) {
    throw UnimplementedError();
  }

  @override
  Future<Publication> getPublicationById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Publication>> searchPublications(String keyword) {
    throw UnimplementedError();
  }
}

void main() {
  test('emits top journals with analysis success', () async {
    final repository = FakePublicationRepository();
    final bloc = AnalysisBloc(
      getPublicationsTrend: GetPublicationsTrend(repository),
      getTopKeywords: GetTopKeywords(repository),
      getTopAuthors: GetTopAuthors(repository),
      getTopJournals: GetTopJournals(repository),
    );

    final emittedStates = <AnalysisState>[];
    final subscription = bloc.stream.listen(emittedStates.add);

    bloc.add(const FetchAnalysisEvent('artificial intelligence'));

    await expectLater(
      bloc.stream,
      emitsThrough(isA<AnalysisSuccess>()),
    );

    final success = emittedStates.whereType<AnalysisSuccess>().single;
    expect(success.topJournals, hasLength(2));
    expect(success.topJournals.first['key_display_name'], 'Journal of Machine Learning Research');
    expect(success.topJournals.first['count'], 42);

    await subscription.cancel();
    await bloc.close();
  });
}
```

- [ ] **Step 2: Run the test and verify it fails**

Run:

```powershell
flutter test test/presentation/bloc/analysis/analysis_bloc_test.dart
```

Expected: FAIL because `AnalysisBloc` does not accept `getTopJournals` and `AnalysisSuccess` does not expose `topJournals`.

- [ ] **Step 3: Update `AnalysisSuccess` state**

Modify `lib/presentation/bloc/analysis/analysis_state.dart` so `AnalysisSuccess` becomes:

```dart
class AnalysisSuccess extends AnalysisState {
  final Map<int, int> trendData;
  final List<Map<String, dynamic>> topKeywords;
  final List<Map<String, dynamic>> topAuthors;
  final List<Map<String, dynamic>> topJournals;
  final String keyword;

  const AnalysisSuccess({
    required this.trendData,
    required this.topKeywords,
    required this.topAuthors,
    required this.topJournals,
    required this.keyword,
  });

  @override
  List<Object?> get props => [trendData, topKeywords, topAuthors, topJournals, keyword];
}
```

- [ ] **Step 4: Update `AnalysisBloc` dependencies and fetch logic**

Modify `lib/presentation/bloc/analysis/analysis_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_publications_trend.dart';
import '../../../domain/usecases/get_top_keywords.dart';
import '../../../domain/usecases/get_top_authors.dart';
import '../../../domain/usecases/get_top_journals.dart';
import 'analysis_event.dart';
import 'analysis_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final GetPublicationsTrend getPublicationsTrend;
  final GetTopKeywords getTopKeywords;
  final GetTopAuthors getTopAuthors;
  final GetTopJournals getTopJournals;

  AnalysisBloc({
    required this.getPublicationsTrend,
    required this.getTopKeywords,
    required this.getTopAuthors,
    required this.getTopJournals,
  }) : super(AnalysisInitial()) {
    on<FetchAnalysisEvent>((event, emit) async {
      if (event.keyword.trim().isEmpty) {
        emit(AnalysisInitial());
        return;
      }

      emit(AnalysisLoading());

      try {
        final results = await Future.wait([
          getPublicationsTrend(event.keyword),
          getTopKeywords(event.keyword),
          getTopAuthors(event.keyword),
          getTopJournals(event.keyword),
        ]);

        final trendData = results[0] as Map<int, int>;
        final topKeywords = results[1] as List<Map<String, dynamic>>;
        final topAuthors = results[2] as List<Map<String, dynamic>>;
        final topJournals = results[3] as List<Map<String, dynamic>>;

        emit(AnalysisSuccess(
          trendData: trendData,
          topKeywords: topKeywords,
          topAuthors: topAuthors,
          topJournals: topJournals,
          keyword: event.keyword,
        ));
      } catch (e) {
        emit(AnalysisFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
```

- [ ] **Step 5: Update dependency injection**

Modify `lib/injection_container.dart`:

```dart
import 'domain/usecases/get_top_journals.dart';
```

Update the `AnalysisBloc` registration:

```dart
sl.registerFactory(
  () => AnalysisBloc(
    getPublicationsTrend: sl(),
    getTopKeywords: sl(),
    getTopAuthors: sl(),
    getTopJournals: sl(),
  ),
);
```

Register the use case:

```dart
sl.registerLazySingleton(() => GetTopJournals(sl()));
```

- [ ] **Step 6: Run the BLoC test and verify it passes**

Run:

```powershell
flutter test test/presentation/bloc/analysis/analysis_bloc_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit**

```powershell
git add lib/presentation/bloc/analysis/analysis_state.dart lib/presentation/bloc/analysis/analysis_bloc.dart lib/injection_container.dart test/presentation/bloc/analysis/analysis_bloc_test.dart
git commit -m "feat: expose top journals in analysis state"
```

---

### Task 3: Replace Top Keywords Slide With Top Journals Slide

**Files:**
- Modify: `lib/presentation/screens/analysis_screen.dart`
- Test manually through the app UI.

- [ ] **Step 1: Update carousel routing**

In `lib/presentation/screens/analysis_screen.dart`, replace the `pageIndex == 1` branch:

```dart
} else if (pageIndex == 1) {
  return _buildTopJournalsSlide(context, state.topJournals, state.keyword);
} else {
  return _buildAuthorImpactSlide(context, state.topAuthors, state.keyword);
}
```

- [ ] **Step 2: Replace `_buildTopKeywordsSlide` with `_buildTopJournalsSlide`**

Remove the `_buildTopKeywordsSlide` method and add:

```dart
// --- Slide 2: Top Research Journals (Ranked Bars) ---
Widget _buildTopJournalsSlide(BuildContext context, List<Map<String, dynamic>> journalsData, String keyword) {
  final topList = journalsData
      .where((data) {
        final name = data['key_display_name']?.toString().trim() ?? '';
        return name.isNotEmpty && name.toLowerCase() != 'unknown';
      })
      .take(5)
      .toList();
  final maxCount = topList.isNotEmpty ? (topList.first['count'] as int? ?? 100).toDouble() : 100.0;

  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 40.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDiagramHeader(title: 'Top Research Journals', topic: keyword),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassBox(
            color: AppTheme.darkCardBackground.withOpacity(0.4),
          ),
          child: topList.isEmpty
              ? const Center(
                  child: Text(
                    'No journal data available',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : Column(
                  children: topList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final name = data['key_display_name']?.toString() ?? 'Unknown Journal';
                    final count = data['count'] as int? ?? 0;
                    final ratio = maxCount > 0 ? count / maxCount : 0.0;

                    return Padding(
                      padding: EdgeInsets.only(bottom: index == topList.length - 1 ? 0 : 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNeon.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.35)),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: AppTheme.primaryNeon,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$count papers',
                                      style: const TextStyle(
                                        color: AppTheme.secondaryNeon,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 10,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.borderNeon.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: ratio.clamp(0.05, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          gradient: const LinearGradient(
                                            colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 3: Run static analysis**

Run:

```powershell
flutter analyze
```

Expected: no new errors caused by the top journals changes.

- [ ] **Step 4: Run all tests**

Run:

```powershell
flutter test
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```powershell
git add lib/presentation/screens/analysis_screen.dart
git commit -m "feat: show ranked top research journals"
```

---

### Task 4: Manual Verification Against Requirement 4.5

**Files:**
- No source changes expected.

- [ ] **Step 1: Run the app**

Run:

```powershell
flutter run
```

Expected: app launches on an Android emulator or connected Android device.

- [ ] **Step 2: Search for a topic**

Use the Search tab and search:

```text
Artificial Intelligence
```

Expected: search results load, and analysis/dashboard data prefetch starts.

- [ ] **Step 3: Open Trend Analysis**

Navigate to the Trends tab.

Expected:
- Carousel slide 1 shows Publication Trend.
- Carousel slide 2 shows Top Research Journals.
- Carousel slide 3 shows Author Impact.

- [ ] **Step 4: Verify the Top Research Journals slide**

Expected:
- The slide title is `Top Research Journals`.
- It shows up to five journal/source names.
- Each row has a rank number.
- Each row shows a publication count with `papers`.
- Bar lengths are proportional to publication counts.
- Empty journal results display `No journal data available`.

- [ ] **Step 5: Verify requirement wording**

Confirm the implementation satisfies section 4.5:

```text
The application shall identify journals that contribute the largest number of publications related to the selected research topic. The result should be presented using a ranked list or chart.
```

Expected: PASS, because the app uses OpenAlex grouped journal counts and displays them as a ranked chart/list.

- [ ] **Step 6: Commit manual verification note if a report file exists**

If the project report is already tracked in the repo, update its feature checklist with:

```text
4.5 Top Research Journals: Implemented with OpenAlex source grouping and ranked top-five chart in Trend Analysis.
```

Then commit:

```powershell
git add <report-file-path>
git commit -m "docs: document top journals implementation"
```

If no report file exists, do not create one for this task.

---

## Self-Review

- Spec coverage: Requirement 4.5 is covered by Task 1 data access use case, Task 2 BLoC state wiring, Task 3 ranked UI, and Task 4 manual verification.
- Placeholder scan: No `TBD`, `TODO`, vague error handling, or undefined implementation steps remain.
- Type consistency: `GetTopJournals`, `topJournals`, `getTopJournals`, and `List<Map<String, dynamic>>` are used consistently across tests, BLoC, state, DI, and UI.
