# Lab03 Patrol Keyword Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete Lab03 Patrol Test Case 2, Test Case 6, and Test Case 7 with simple tests matching the style of the existing `integration_test/journal_flow_test.dart`.

**Architecture:** Keep all changes in `integration_test/keyword_flow_test.dart`. Use `patrolTest`, mocked services, direct screen pumping, and deterministic assertions. Avoid full app routing, Firebase Auth, real Firebase, real OpenAlex, and unrelated workflows.

**Tech Stack:** Flutter, Dart, Provider, GetIt, Patrol `patrolTest`, existing mock services.

## Global Constraints

- Scope is limited to Lab03 Test Case 2, Test Case 6, and Test Case 7.
- Keep the tests simple and consistent with existing tests such as `integration_test/journal_flow_test.dart`.
- Use `patrolTest` in `integration_test/keyword_flow_test.dart`.
- Use existing deterministic mock data from `integration_test/mock_services.dart`.
- Do not add live Firebase verification, Google Sign-In, real OpenAlex API calls, PDF export, journal tests, or full app authentication routing.
- Do not introduce a full `GoRouter`/`MainShell` harness unless a direct screen pump cannot satisfy the case.

---

## File Structure

- Modify: `integration_test/keyword_flow_test.dart`
  - Owns Test Case 2, Test Case 6, and Test Case 7.
  - Should stay similar in style to `integration_test/journal_flow_test.dart`.
- Reuse: `integration_test/mock_services.dart`
  - Provides `MockOpenAlexService` and `MockAnalyticsService`.
- Reuse: `lib/screens/home_screen.dart`
  - Used by Test Case 2.
- Reuse: `lib/screens/keywords_screen.dart`
  - Used by Test Case 6.
- Reuse: `lib/screens/keyword_detail_screen.dart`
  - Used by Test Case 7.

---

### Task 1: Keep Topic Search Test Simple and Complete

**Files:**
- Modify: `integration_test/keyword_flow_test.dart`
- Test: `integration_test/keyword_flow_test.dart`

**Interfaces:**
- Consumes: `MockOpenAlexService`, `MockAnalyticsService`, `SearchViewModel`, `AnalysisViewModel`, `DashboardViewModel`, `KeywordViewModel`, `JournalViewModel`, `HomeScreen`.
- Produces: Test Case 2 that searches a topic, displays publication results, and records `search_topic`.

- [ ] **Step 1: Ensure imports include `JournalViewModel`**

```dart
import '../lib/viewmodels/journal_viewmodel.dart';
```

- [ ] **Step 2: Pump `HomeScreen` directly with required providers**

Use this provider setup in Test Case 2:

```dart
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
```

- [ ] **Step 3: Search and verify visible results plus analytics**

```dart
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
```

- [ ] **Step 4: Commit**

```bash
git add integration_test/keyword_flow_test.dart
git commit -m "test: cover lab03 topic search patrol case"
```

---

### Task 2: Simplify Keywords Navigation Test

**Files:**
- Modify: `integration_test/keyword_flow_test.dart`
- Test: `integration_test/keyword_flow_test.dart`

**Interfaces:**
- Consumes: `MockOpenAlexService`, `KeywordViewModel`, `KeywordsScreen`.
- Produces: Test Case 6 that displays the Keywords screen with keyword list and concrete keyword statistics.

- [ ] **Step 1: Pump `KeywordsScreen` directly with preloaded data**

This matches the existing `journal_flow_test.dart` style, where the destination screen is pumped directly with a preloaded view model.

```dart
final openAlex = MockOpenAlexService();
final keywordViewModel = KeywordViewModel(openAlexService: openAlex);
await keywordViewModel.loadForTopic('Artificial Intelligence');

await $.pumpWidgetAndSettle(
  ChangeNotifierProvider.value(
    value: keywordViewModel,
    child: const MaterialApp(home: KeywordsScreen()),
  ),
);
```

- [ ] **Step 2: Verify keyword screen, list, and statistics**

```dart
expect($('Keywords'), findsOneWidget);
expect($('Topic: Artificial Intelligence'), findsOneWidget);
expect($('Most Frequent Keywords'), findsOneWidget);
expect($('Trending Keywords'), findsOneWidget);
expect($('Machine Learning'), findsWidgets);
expect($('Deep Learning'), findsWidgets);
expect($('12 publications'), findsWidgets);

await $.scrollUntilVisible(
  finder: $('Keyword Frequency Statistics'),
  view: find.byType(Scrollable),
  delta: const Offset(0, -300),
);
expect($('Keyword Frequency Statistics'), findsOneWidget);
expect($('60.0% of matching topic publications'), findsOneWidget);
expect($('Most active year: 2025'), findsOneWidget);
expect($('Growth: +8 publications'), findsOneWidget);

await $.scrollUntilVisible(
  finder: $('Keyword Trend Charts'),
  view: find.byType(Scrollable),
  delta: const Offset(0, -300),
);
expect($('Keyword Trend Charts'), findsOneWidget);
```

- [ ] **Step 3: Commit**

```bash
git add integration_test/keyword_flow_test.dart
git commit -m "test: simplify lab03 keywords patrol case"
```

---

### Task 3: Simplify Keyword Details Test

**Files:**
- Modify: `integration_test/keyword_flow_test.dart`
- Test: `integration_test/keyword_flow_test.dart`

**Interfaces:**
- Consumes: `MockOpenAlexService`, `MockAnalyticsService`, `KeywordViewModel`, `KeywordDetailScreen`, `GetIt`.
- Produces: Test Case 7 that displays keyword analysis details and records `view_keyword`.

- [ ] **Step 1: Pump `KeywordDetailScreen` directly with required provider**

This matches the style of `integration_test/journal_flow_test.dart`, where Test Case 5 pumps `JournalDetailScreen` directly.

```dart
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
        count: 10,
      ),
    ),
  ),
);
```

- [ ] **Step 2: Verify keyword detail analysis and analytics event**

```dart
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
```

- [ ] **Step 3: Commit**

```bash
git add integration_test/keyword_flow_test.dart
git commit -m "test: simplify lab03 keyword detail patrol case"
```

---

### Task 4: Final Verification

**Files:**
- Test: `integration_test/keyword_flow_test.dart`

**Interfaces:**
- Consumes: final Test Case 2, 6, and 7 implementation.
- Produces: concise verification notes for the final response.

- [ ] **Step 1: Format touched test file**

```bash
dart format integration_test/keyword_flow_test.dart
```

- [ ] **Step 2: Run Patrol target if available**

```bash
patrol test --target integration_test/keyword_flow_test.dart
```

Expected when Patrol and an Android emulator are available:

```text
All tests passed!
```

If Patrol CLI or emulator is unavailable, record the exact error.

- [ ] **Step 3: Run Flutter integration test fallback**

```bash
flutter test integration_test/keyword_flow_test.dart
```

If no single integration-test device is available, record the exact device-selection error.

---

## Self-Review

- Test Case 2 covers entering a topic, executing search, verifying publication results, and `search_topic`.
- Test Case 6 covers the Keywords screen, keyword list, and concrete keyword statistics with deterministic mock data.
- Test Case 7 covers keyword detail analysis information and `view_keyword`.
- The plan intentionally avoids full routing/auth/Firebase setup so it remains consistent with existing Patrol tests in the repository.
