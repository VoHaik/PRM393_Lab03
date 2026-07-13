# Keywords Flow Implementation Plan

## Purpose

Implement the missing Keywords flow for Lab 03 while keeping the current app structure intact.

The app will keep the existing bottom navigation tabs and add one new tab:

```text
Search | Trends | Dashboard | Keywords | Profile
```

This plan focuses only on:

- Keywords screen
- Keyword detail screen
- `view_keyword` analytics event
- Patrol Test 2, Test 6, and Test 7

The plan intentionally avoids unrelated Lab 03 work such as Journals, Firebase Storage, FCM, Remote Config, Crashlytics, and Home redesign.

## Current Implementation Status

Already implemented:

- Topic search through `SearchScreen` and `SearchViewModel`.
- OpenAlex publication search through `OpenAlexService.searchPublications`.
- Dashboard statistics through `DashboardScreen`, `DashboardViewModel`, and `OpenAlexService.getAnalyticsSummary`.
- Trends chart through `AnalysisScreen`, `AnalysisViewModel`, and `OpenAlexService.getPublicationsTrend`.
- Keyword aggregation through `OpenAlexService.getTopKeywords`.
- Author and journal aggregation through `OpenAlexService.getTopAuthors` and `OpenAlexService.getTopJournals`.
- `search_topic` analytics event in `SearchViewModel.searchTopic`.
- `AnalyticsService.logViewKeyword`, currently available but not used by any screen.
- Basic Patrol tests for authentication and analytics flow.

Missing:

- Dedicated Keywords tab.
- Dedicated Keywords screen.
- Dedicated Keyword Detail screen.
- Route for keyword list and keyword detail.
- UI action that logs `view_keyword`.
- Patrol Test 2 focused on search result verification.
- Patrol Test 6 for Keywords navigation.
- Patrol Test 7 for Keyword Details.

## Scope

### In Scope

1. Add a new `Keywords` tab to the existing bottom navigation.
2. Add a `KeywordsScreen` that displays keyword analysis for the current searched topic.
3. Add a `KeywordDetailScreen` that displays details for one selected keyword.
4. Reuse existing OpenAlex data and view models where possible.
5. Trigger `view_keyword` when the keyword detail screen opens.
6. Add Patrol coverage for required test cases 2, 6, and 7.

### Out of Scope

- No Journals tab or journal detail implementation.
- No redesign of Home/Search/Dashboard.
- No PDF export.
- No Firebase Storage.
- No Firebase Cloud Messaging.
- No Firebase Remote Config.
- No Firebase Crashlytics.
- No broad MVVM refactor.
- No new state management library.

## Proposed File Changes

### Modify `lib/widgets/main_shell.dart`

Add one new bottom navigation item:

```text
Keywords
```

Expected tab order:

```text
0 Search
1 Trends
2 Dashboard
3 Keywords
4 Profile
```

Update selected-index detection so `/keywords` and `/keyword-detail` map to the Keywords tab.

### Modify `lib/utils/navigation/router.dart`

Add routes:

```text
/keywords
/keyword-detail
```

`/keywords` will render `KeywordsScreen`.

`/keyword-detail` will render `KeywordDetailScreen` and receive the selected keyword data through `state.extra`.

### Add `lib/screens/keywords_screen.dart`

Responsibilities:

- Read keyword data from `AnalysisViewModel`.
- Display the active searched topic.
- Display top keywords from `AnalysisViewModel.topKeywords`.
- Show count/frequency for each keyword.
- Show loading, error, and empty states using the existing app style.
- Navigate to `/keyword-detail` when a keyword is tapped.

Data source:

```dart
context.watch<AnalysisViewModel>()
```

No new API call is required for the first version because `SearchScreen._triggerSearch` already calls:

```dart
context.read<AnalysisViewModel>().fetchAnalysis(trimmedKeyword)
```

### Add `lib/screens/keyword_detail_screen.dart`

Responsibilities:

- Display selected keyword name.
- Display keyword frequency/count.
- Display publication trend chart using existing `AnalysisViewModel.trendData`.
- Display related journals using existing `AnalysisViewModel.topJournals`.
- Display top contributing authors using existing `AnalysisViewModel.topAuthors`.
- Display related publications using existing `SearchViewModel.publications`.
- Log `AnalyticsService.logViewKeyword(keyword)` once when the screen opens.

The screen will not perform complex new analysis. It will present already-loaded data in a focused detail view.

### Modify `lib/injection_container.dart`

No new service is expected.

If a dedicated `KeywordViewModel` becomes necessary during implementation, it should only wrap existing data access and should not duplicate `AnalysisViewModel` logic. The preferred approach is no new ViewModel unless the implementation becomes awkward.

### Modify Patrol Tests

Current tests:

```text
integration_test/auth_flow_test.dart
integration_test/analytics_flow_test.dart
```

Planned test coverage:

#### Test Case 2 - Topic Search

Verify:

- App logs in with mock auth.
- User enters a topic.
- User triggers search.
- Search result UI appears.
- At least one publication card or result label is visible.

#### Test Case 6 - Keywords Navigation

Verify:

- App logs in.
- User searches a topic.
- User taps `Keywords` tab.
- Keywords screen appears.
- Keyword list or keyword empty state appears.

Preferred result: deterministic keyword list using a fake OpenAlex service.

#### Test Case 7 - Keyword Details

Verify:

- App logs in.
- User searches a topic.
- User opens `Keywords` tab.
- User taps a keyword.
- Keyword detail screen appears.
- Selected keyword name is displayed.
- `view_keyword` analytics event is logged with the selected keyword parameter.

### Modify `integration_test/mock_services.dart`

If current tests require live OpenAlex data, add a mock/fake OpenAlex service for deterministic tests.

The fake service should return:

- A small publication list.
- A small publication trend map.
- A small top keyword list.
- A small top author list.
- A small top journal list.
- A simple analytics summary.

This keeps Patrol tests stable and avoids depending on network/API timing.

## Data Flow

1. User searches in `SearchScreen`.
2. `SearchViewModel.searchTopic` fetches publications and logs `search_topic`.
3. `SearchScreen._triggerSearch` also calls:
   - `AnalysisViewModel.fetchAnalysis`
   - `DashboardViewModel.fetchDashboard`
4. User opens the new `Keywords` tab.
5. `KeywordsScreen` reads `AnalysisViewModel.topKeywords`.
6. User taps a keyword.
7. `KeywordDetailScreen` opens.
8. `KeywordDetailScreen` logs `view_keyword`.
9. `KeywordDetailScreen` displays existing trend, journal, author, and publication data.

## Error Handling

The Keywords screen should follow existing screen patterns:

- If no topic has been searched, show an empty state asking the user to search first.
- If `AnalysisViewModel.isLoading` is true, show loading.
- If `AnalysisViewModel.errorMessage` is set, show the error.
- If no keywords are available, show a clear empty state.

The Keyword Detail screen should tolerate missing related data:

- No trend data: show "No trend data available."
- No related journals: show "No related journals available."
- No authors: show "No author ranking available."
- No publications: show "No related publications available."

## Testing and Verification

Run after implementation:

```text
flutter analyze
flutter test
patrol test --target integration_test/analytics_flow_test.dart
```

If new Patrol test files are added, run those specific files as well.

If Patrol CLI or emulator is unavailable, document that limitation in the walkthrough.

## Acceptance Criteria

The work is complete when:

- Bottom navigation includes `Keywords`.
- `/keywords` opens a Keywords screen.
- Keywords screen displays keyword data after a topic search.
- Tapping a keyword opens Keyword Detail.
- Keyword Detail displays the selected keyword.
- Opening Keyword Detail logs `view_keyword`.
- Existing `search_topic` behavior still works.
- Patrol Test 2, 6, and 7 are implemented.
- Static analysis passes.
- Project map is updated after implementation.

## Implementation Order

1. Add routes and bottom navigation entry.
2. Add `KeywordsScreen`.
3. Add `KeywordDetailScreen`.
4. Wire `view_keyword` analytics.
5. Add deterministic mock OpenAlex test data if needed.
6. Add Patrol Test 2.
7. Add Patrol Test 6.
8. Add Patrol Test 7.
9. Run verification.
10. Update `docs/PROJECT_MAP.md`.
11. Write final walkthrough after implementation.

