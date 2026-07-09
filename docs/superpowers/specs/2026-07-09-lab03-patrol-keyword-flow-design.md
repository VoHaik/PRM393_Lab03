# Lab03 Patrol Keyword Flow Design

## Goal

Complete the Patrol test coverage for Lab03 Test Case 2, Test Case 6, and Test Case 7 while keeping the work limited to those cases. The tests should match the lab wording closely, remain easy to explain in the project report, and avoid dependencies on live Firebase, authentication, OpenAlex network calls, or unrelated lab features.

## Lab Requirements Covered

- Test Case 2 - Topic Search: enter a research topic, execute search, and verify publication results are displayed.
- Test Case 6 - Keywords Navigation: navigate to the Keywords tab and verify keyword statistics and keyword list are displayed.
- Test Case 7 - Keyword Details: open a keyword from the keyword list and verify keyword analysis information is displayed.

## Recommended Approach

Use minimal lab-compliant Patrol flow tests in `integration_test/keyword_flow_test.dart`.

The tests will still use `patrolTest`, mocked services, and deterministic in-memory data. This keeps the tests stable and focused on the UI workflows required by Lab03, rather than testing external services. The existing mock services in `integration_test/mock_services.dart` will continue to provide search results, keyword analytics, keyword detail data, and analytics event capture.

## Test Case 2 Design

Test Case 2 will continue to pump the Home screen with mocked view models and services. The test will:

- Enter `Artificial Intelligence` in the topic search field.
- Tap the search action.
- Verify the publication result list contains the deterministic mock paper.
- Verify the mock analytics service records `search_topic` with `keyword = Artificial Intelligence`.

This satisfies the lab requirement because the test performs the visible search workflow and verifies displayed publication results.

## Test Case 6 Design

Test Case 6 will be changed from directly pumping `KeywordsScreen` to a small test app that includes navigation to the Keywords tab.

The test will:

- Set up providers with `KeywordViewModel` preloaded for `Artificial Intelligence`.
- Pump a minimal app surface with Home and Keywords destinations.
- Tap the `Keywords` tab.
- Verify the Keywords screen is visible.
- Verify keyword analytics sections are displayed:
  - `Most Frequent Keywords`
  - `Trending Keywords`
  - `Keyword Frequency Statistics`
  - `Keyword Trend Charts`
- Verify keyword list entries such as `Machine Learning` and `Deep Learning`.

This satisfies the lab requirement because it explicitly tests navigation to the Keywords tab and verifies keyword statistics and list content.

## Test Case 7 Design

Test Case 7 will be changed from directly pumping `KeywordDetailScreen` to opening a keyword from the keyword list.

The test will:

- Start from the Keywords screen with deterministic keyword analytics data.
- Tap a keyword card, preferably `Deep Learning`.
- Navigate to `KeywordDetailScreen` using the same route behavior as the app.
- Verify keyword analysis information is displayed, including the selected keyword, related publication, related journal, top author, and publication count.
- Verify the mock analytics service records `view_keyword` with the selected keyword.

This satisfies the lab requirement because the test opens a keyword from the list before checking the detail analysis.

## Scope Boundaries

The work will not add live Firebase verification, Google Sign-In, real OpenAlex API calls, PDF export, journal tests, or full app authentication routing. Those are outside the requested scope of Test Case 2, Test Case 6, and Test Case 7.

The work should not require production UI changes unless a missing test hook or route prevents the lab workflow from being tested. If a production change is needed, it should be small and directly justified by the test flow.

## Verification

Primary verification command:

```bash
patrol test --target integration_test/keyword_flow_test.dart
```

Fallback verification, when Patrol CLI or emulator tooling is unavailable, is to run the closest supported Flutter tests and document the exact environment limitation. The test implementation should not be weakened to work around missing local tooling.
