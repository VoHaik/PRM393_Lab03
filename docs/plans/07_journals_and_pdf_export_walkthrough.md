# Walkthrough - Journals and PDF Export

This walkthrough summarizes the changes made to the **Journal Trend Analyzer** application to implement the **Journals Analysis** and **PDF Report Export** modules.

---

## Changes Made

### 1. Model Layer
*   **[NEW] [journal_detail.dart](file:///d:/PRM_CP3/lib/models/journal_detail.dart):** Data structures for journal detail metadata (total publications, citations count, average citation per publication, and a list of related `Publication` objects).

### 2. Service Layer
*   **[MODIFY] [openalex_service.dart](file:///d:/PRM_CP3/lib/services/openalex_service.dart):** Implemented `getJournalDetail(String journalId, String keyword)` to fetch journal details and related works concurrently.
*   **[NEW] [report_service.dart](file:///d:/PRM_CP3/lib/services/report_service.dart):** Generates structured PDF reports in-memory using the `pdf` package, detailing the topic keyword, bibliometric metrics, and top entities.
*   **[NEW] [storage_service.dart](file:///d:/PRM_CP3/lib/services/storage_service.dart):** Uploads generated PDF files to Firebase Storage and returns the public download URL.

### 3. ViewModel Layer
*   **[NEW] [journal_viewmodel.dart](file:///d:/PRM_CP3/lib/viewmodels/journal_viewmodel.dart):** Manages list loading, top journals ranking, detail loading, and logs the `view_journal` event to Firebase Analytics.
*   **[NEW] [profile_viewmodel.dart](file:///d:/PRM_CP3/lib/viewmodels/profile_viewmodel.dart):** Coordinates PDF report generation and uploading. Logs the `export_pdf` event.
*   **[MODIFY] [injection_container.dart](file:///d:/PRM_CP3/lib/injection_container.dart):** Registered the new viewmodels and services.

### 4. View / UI Layer
*   **[MODIFY] [main.dart](file:///d:/PRM_CP3/lib/main.dart):** Provided the new `JournalViewModel` and `ProfileViewModel` globally in `MultiProvider`.
*   **[MODIFY] [main_shell.dart](file:///d:/PRM_CP3/lib/widgets/main_shell.dart):** Refactored the Bottom Navigation Bar to exactly 4 tabs (Home, Journals, Keywords, Profile) to match the Lab 03 requirements.
*   **[MODIFY] [router.dart](file:///d:/PRM_CP3/lib/utils/navigation/router.dart):** Configured paths `/home`, `/journals`, and `/journal-detail`.
*   **[NEW] [home_screen.dart](file:///d:/PRM_CP3/lib/screens/home_screen.dart):** Merges Search, Trends chart (FlChart), and Dashboard overview stats into a unified tabbed dashboard view.
*   **[NEW] [journals_screen.dart](file:///d:/PRM_CP3/lib/screens/journals_screen.dart):** Displays ranked top journals list, contribution shares progress bars, and citation statistics.
*   **[NEW] [journal_detail_screen.dart](file:///d:/PRM_CP3/lib/screens/journal_detail_screen.dart):** Displays total publications, citations, average citation count, and related publications.
*   **[MODIFY] [profile_screen.dart](file:///d:/PRM_CP3/lib/screens/profile_screen.dart):** Wired the "Report Export & Storage" demo card to generate a PDF report, upload it to Firebase Storage, show progress/success indicators, and allow copying and opening the download URL.

### 5. Automated Tests
*   **[MODIFY] [mock_services.dart](file:///d:/PRM_CP3/integration_test/mock_services.dart):** Added `MockStorageService`, `MockReportService`, and mocked journal details loading.
*   **[NEW] [journal_flow_test.dart](file:///d:/PRM_CP3/integration_test/journal_flow_test.dart):** Patrol E2E tests for Test Case 4 (Journals Navigation) and Test Case 5 (Journal Details).
*   **[NEW] [export_flow_test.dart](file:///d:/PRM_CP3/integration_test/export_flow_test.dart):** Patrol E2E test for Test Case 9 (PDF Export & Storage upload).
*   **[MODIFY] [keyword_flow_test.dart](file:///d:/PRM_CP3/integration_test/keyword_flow_test.dart) & [keywords_flow_test.dart](file:///d:/PRM_CP3/test/screens/keywords_flow_test.dart):** Updated legacy references to the search screen to target the new home screen.

---

## Verification Results

### Static Analysis
`flutter analyze` executes successfully with **0 compiler errors** and **0 code warnings** across the codebase.

### Test Execution
*   Unit/Widget Tests: All tests pass successfully.
*   E2E Patrol Tests: Implemented E2E test cases (4, 5, and 9) verify UI renders correctly and triggers correct analytics events (`view_journal`, `export_pdf`).
