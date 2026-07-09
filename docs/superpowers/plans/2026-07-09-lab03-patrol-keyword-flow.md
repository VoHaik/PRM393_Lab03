# Lab03 Patrol Keyword Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete Lab03 Patrol coverage for Test Case 2, Test Case 6, and Test Case 7 with simple workflow tests that match the assignment wording.

**Architecture:** Keep all behavior under `integration_test/keyword_flow_test.dart` and the existing deterministic mocks in `integration_test/mock_services.dart`. Use a lightweight `GoRouter` test harness with the real `MainShell`, `KeywordsScreen`, and `KeywordDetailScreen` so navigation is tested without Firebase Auth, live Firebase Analytics, or OpenAlex network calls.

**Tech Stack:** Flutter, Dart, Provider, GoRouter, GetIt, Patrol `patrolTest`, Flutter integration testing, existing mock services.

## Global Constraints

- Scope is limited to Lab03 Test Case 2, Test Case 6, and Test Case 7.
- Do not add live Firebase verification, Google Sign-In, real OpenAlex API calls, PDF export, journal tests, or full app authentication routing.
- Use `patrolTest` in `integration_test/keyword_flow_test.dart`.
- Use existing deterministic mock data from `integration_test/mock_services.dart`.
- Prefer no production code changes; only add a production change if a missing route or test hook directly blocks the required lab workflow.
- Mirror plan documentation in `docs/plans/` using `[XX]_[lowercase_snake_case_topic]_[file_type].md`.

---

## File Structure

- Modify: `integration_test/keyword_flow_test.dart`
  - Owns Patrol tests for Lab03 Test Case 2, Test Case 6, and Test Case 7.
  - Will add focused test harness helpers for provider setup and navigation.
- Reuse: `integration_test/mock_services.dart`
  - Provides `MockOpenAlexService` and `MockAnalyticsService`.
  - No changes expected unless current mock data cannot satisfy visible assertions.
- Reuse: `lib/widgets/main_shell.dart`
  - Provides the real bottom navigation bar used by the test harness.
- Reuse: `lib/screens/home_screen.dart`
  - Used by Test Case 2 topic search.
- Reuse: `lib/screens/keywords_screen.dart`
  - Used by Test Case 6 navigation and Test Case 7 keyword selection.
- Reuse: `lib/screens/keyword_detail_screen.dart`
  - Used by Test Case 7 detail verification.

---

### Task 1: Stabilize Topic Search Test Providers

**Files:**
- Modify: `integration_test/keyword_flow_test.dart`
- Test: `integration_test/keyword_flow_test.dart`

**Interfaces:**
- Consumes: `MockOpenAlexService`, `MockAnalyticsService`, `SearchViewModel`, `AnalysisViewModel`, `DashboardViewModel`, `KeywordViewModel`, `JournalViewModel`, `HomeScreen`.
- Produces: Test Case 2 that can execute `HomeScreen._triggerSearch()` without a missing `JournalViewModel` provider.

- [ ] **Step 1: Update imports for `JournalViewModel`**

Add this import near the other view model imports in `integration_test/keyword_flow_test.dart`:

```dart
import '../lib/viewmodels/journal_viewmodel.dart';
```

- [ ] **Step 2: Update Test Case 2 provider setup**

Replace the current `MultiProvider` providers in Test Case 2 with this provider list:

```dart
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
```

- [ ] **Step 3: Use a deterministic wait after search**

Replace the current settle after tapping search:

```dart
await $.pumpAndSettle();
```

with:

```dart
await $.pump();
await $.pump(const Duration(seconds: 2));
await $.pumpAndSettle();
```

This accounts for the delayed analysis, keyword, dashboard, and journal preload calls inside `HomeScreen._triggerSearch()`.

- [ ] **Step 4: Run the targeted Flutter widget/integration check**

Run:

```bash
flutter test integration_test/keyword_flow_test.dart
```

Expected if no device is selected:

```text
More than one device connected; please specify a device with the '-d <deviceId>' flag
```

If this appears, continue to Task 4 for Patrol device verification. If it runs on a selected local test device, Test Case 2 should not fail with `ProviderNotFoundException`.

- [ ] **Step 5: Commit Task 1**

```bash
git add integration_test/keyword_flow_test.dart
git commit -m "test: stabilize patrol topic search providers"
```

---

### Task 2: Add Navigation Harness for Keywords Tab

**Files:**
- Modify: `integration_test/keyword_flow_test.dart`
- Test: `integration_test/keyword_flow_test.dart`

**Interfaces:**
- Consumes: `GoRouter`, `ShellRoute`, `GoRoute`, `MainShell`, `KeywordsScreen`, `KeywordDetailScreen`, `KeywordViewModel`.
- Produces: `_buildKeywordFlowApp(...)` helper returning a `Widget` that supports bottom-tab navigation to `/keywords` and route navigation to `/keyword-detail`.

- [ ] **Step 1: Add imports for router and shell**

Add these imports in `integration_test/keyword_flow_test.dart`:

```dart
import 'package:go_router/go_router.dart';

import '../lib/widgets/main_shell.dart';
```

- [ ] **Step 2: Add the keyword flow test app helper**

Add this helper above `void main()` in `integration_test/keyword_flow_test.dart`:

```dart
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
```

This helper intentionally avoids the production `AppRouter` because that router redirects through `FirebaseAuth.instance.currentUser`, which is outside the scope of Test Case 2, Test Case 6, and Test Case 7.

- [ ] **Step 3: Run analyzer on the modified test file**

Run:

```bash
flutter analyze integration_test/keyword_flow_test.dart
```

Expected:

```text
No issues found!
```

If the repository analyzer reports unrelated generated-file warnings, ensure no new issues are from `integration_test/keyword_flow_test.dart`.

- [ ] **Step 4: Commit Task 2**

```bash
git add integration_test/keyword_flow_test.dart
git commit -m "test: add keyword patrol navigation harness"
```

---

### Task 3: Rewrite Test Case 6 to Navigate to Keywords Tab

**Files:**
- Modify: `integration_test/keyword_flow_test.dart`
- Test: `integration_test/keyword_flow_test.dart`

**Interfaces:**
- Consumes: `_buildKeywordFlowApp({required KeywordViewModel keywordViewModel, String initialLocation})`.
- Produces: Lab03 Test Case 6 that taps the `Keywords` bottom-nav tab and verifies keyword statistics plus keyword list content.

- [ ] **Step 1: Replace Test Case 6 body**

Replace the current Test Case 6 body with:

```dart
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
```

- [ ] **Step 2: If `$.scrollUntilVisible` signature differs, use Flutter tester scrolling**

If Patrol `$.scrollUntilVisible` does not accept the named arguments above in this project version, replace only the two scroll blocks with:

```dart
await testerScrollUntilVisible($, 'Keyword Frequency Statistics');
expect($('Keyword Frequency Statistics'), findsOneWidget);

await testerScrollUntilVisible($, 'Keyword Trend Charts');
expect($('Keyword Trend Charts'), findsOneWidget);
```

and add this helper above `void main()`:

```dart
Future<void> testerScrollUntilVisible(PatrolIntegrationTester $, String text) async {
  await $.tester.scrollUntilVisible(
    find.text(text),
    300,
    scrollable: find.byType(Scrollable),
  );
  await $.pumpAndSettle();
}
```

Use this fallback only if the Patrol helper signature fails to compile.

- [ ] **Step 3: Run the Dart-level test compile**

Run:

```bash
flutter test integration_test/keyword_flow_test.dart
```

Expected if no single integration-test device is configured:

```text
More than one device connected; please specify a device with the '-d <deviceId>' flag
```

Expected if run on a supported integration-test device:

```text
Test Case 6 - Navigate to Keywords tab and display keyword analytics
```

passes.

- [ ] **Step 4: Commit Task 3**

```bash
git add integration_test/keyword_flow_test.dart
git commit -m "test: cover keywords tab navigation"
```

---

### Task 4: Rewrite Test Case 7 to Open Keyword from List

**Files:**
- Modify: `integration_test/keyword_flow_test.dart`
- Test: `integration_test/keyword_flow_test.dart`

**Interfaces:**
- Consumes: `_buildKeywordFlowApp(...)`, `MockAnalyticsService`, `GetIt.instance`, `KeywordViewModel`.
- Produces: Lab03 Test Case 7 that taps a keyword list item, routes to details, verifies analysis information, and verifies `view_keyword`.

- [ ] **Step 1: Replace Test Case 7 body**

Replace the current Test Case 7 body with:

```dart
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

    await $.tap($('Deep Learning').first);
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
```

Use `10 publications` because `MockOpenAlexService.getKeywordAnalytics()` returns `Deep Learning` with `publicationCount: 10`.

- [ ] **Step 2: If duplicate `Deep Learning` widgets make tap ambiguous, target the first card title**

If the tap hits a non-card duplicate text, replace:

```dart
await $.tap($('Deep Learning').first);
```

with:

```dart
await $.tester.tap(find.text('Deep Learning').first);
await $.pumpAndSettle();
```

This still opens the keyword from the visible keyword list because the first `Deep Learning` occurrence appears in the frequent keyword cards before later statistic/chart duplicates.

- [ ] **Step 3: Run the target Patrol file on an Android emulator**

Start or select an Android emulator, then run:

```bash
patrol test --target integration_test/keyword_flow_test.dart
```

Expected:

```text
Test Case 2 - Topic Search displays publication results
Test Case 6 - Navigate to Keywords tab and display keyword analytics
Test Case 7 - Open keyword from list and display keyword analysis
```

all pass.

- [ ] **Step 4: Commit Task 4**

```bash
git add integration_test/keyword_flow_test.dart
git commit -m "test: cover keyword detail from keyword list"
```

---

### Task 5: Final Verification and Documentation Notes

**Files:**
- Modify: `docs/PROJECT_MAP.md` only if implementation creates or materially changes test structure beyond `integration_test/keyword_flow_test.dart`.
- Test: `integration_test/keyword_flow_test.dart`

**Interfaces:**
- Consumes: final test implementation from Tasks 1-4.
- Produces: verified scope-limited Lab03 Test Case 2/6/7 coverage and concise notes for report/demo.

- [ ] **Step 1: Run formatter**

Run:

```bash
dart format integration_test/keyword_flow_test.dart
```

Expected:

```text
Formatted integration_test/keyword_flow_test.dart
```

or:

```text
Changed 0 files
```

- [ ] **Step 2: Run analyzer for touched test**

Run:

```bash
flutter analyze integration_test/keyword_flow_test.dart
```

Expected:

```text
No issues found!
```

- [ ] **Step 3: Run Patrol target**

Run:

```bash
patrol test --target integration_test/keyword_flow_test.dart
```

Expected:

```text
All tests passed!
```

If Patrol CLI, Android emulator, or device tooling is unavailable, capture the exact terminal error in the final implementation notes and do not change app logic to bypass tooling.

- [ ] **Step 4: Update project map only if needed**

If only `integration_test/keyword_flow_test.dart` changed, no `docs/PROJECT_MAP.md` update is required because it already lists the integration test area generally. If a new helper file is created, add a bullet under the `integration_test/` section:

```markdown
  * `keyword_flow_test.dart`: Patrol tests for Lab03 Test Case 2, Test Case 6, and Test Case 7 covering topic search, Keywords tab navigation, keyword detail navigation, and keyword analytics event logging.
```

- [ ] **Step 5: Final commit**

If Task 5 changed only formatting of already committed files, commit it:

```bash
git add integration_test/keyword_flow_test.dart docs/PROJECT_MAP.md
git commit -m "test: finalize lab03 keyword patrol flow"
```

If there are no changes after verification, do not create an empty commit.

---

## Self-Review

- Spec coverage: Task 1 covers Test Case 2 stability and search verification. Task 3 covers navigation to Keywords tab plus keyword statistics/list verification. Task 4 covers opening a keyword from the list, detail analysis verification, and `view_keyword` analytics logging.
- Placeholder scan: no implementation step uses unfinished-marker language or unspecified "add tests" language.
- Type consistency: helper uses `KeywordViewModel`, `Widget`, `GoRouter`, `ShellRoute`, and route extras matching existing `KeywordsScreen` and `KeywordDetailScreen` behavior.
