# Tasks - Journals and PDF Export

- [x] **Phase 1: Dependencies & Configuration**
  - [x] Add `pdf: ^3.10.8` to `pubspec.yaml`
  - [x] Add `firebase_storage: ^11.2.0` to `pubspec.yaml`
  - [x] Run `flutter pub get` and verify dependency resolution

- [x] **Phase 2: Models & Services**
  - [x] Create `lib/models/journal_detail.dart`
  - [x] Update `lib/services/openalex_service.dart` with `getJournalDetail(String journalId, String keyword)`
  - [x] Create `lib/services/report_service.dart` for PDF generation using `pdf`
  - [x] Create `lib/services/storage_service.dart` for Firebase Storage uploading
  - [x] Register new services in `lib/injection_container.dart`

- [x] **Phase 3: ViewModels & Injection**
  - [x] Create `lib/viewmodels/journal_viewmodel.dart`
  - [x] Create `lib/viewmodels/profile_viewmodel.dart`
  - [x] Register new ViewModels in `lib/injection_container.dart`
  - [x] Provide ViewModels in `lib/main.dart`

- [x] **Phase 4: Navigation, Router, & Home Screen**
  - [x] Update `lib/utils/navigation/router.dart` (Configure GoRouter paths and guards)
  - [x] Update `lib/widgets/main_shell.dart` (Refactor to 4 tabs: Home, Journals, Keywords, Profile)
  - [x] Create `lib/screens/home_screen.dart` (Merge Search, Trends, and Dashboard)
  - [x] Remove or deprecate `lib/screens/search_screen.dart`

- [x] **Phase 5: Journal & Profile Screens UI**
  - [x] Create `lib/screens/journals_screen.dart` (Xếp hạng, charts, navigation)
  - [x] Create `lib/screens/journal_detail_screen.dart` (Total publications/citations/average, related papers list, navigation)
  - [x] Update `lib/screens/profile_screen.dart` (Wire PDF Export & Storage card and trigger dialogs/downloads)

- [x] **Phase 6: E2E Integration Testing**
  - [x] Update `integration_test/mock_services.dart` to support journal detail mock and storage mock
  - [x] Create `integration_test/journal_flow_test.dart` (Test Case 4 & 5)
  - [x] Create `integration_test/export_flow_test.dart` (Test Case 9)

- [x] **Phase 7: Quality Assurance & Verification**
  - [x] Run `flutter analyze` to ensure clean analysis without any errors or warnings
  - [x] Run automated tests via Patrol
  - [x] Update `docs/PROJECT_MAP.md` table and active status log
