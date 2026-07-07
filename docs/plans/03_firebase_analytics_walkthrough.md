# Walkthrough - Firebase Analytics Integration

This walkthrough documents the successful integration of **Firebase Analytics** into the Journal Trend Analyzer project, establishing event tracking hooks for user activity logs as required by the Lab 03 specifications.

---

## 🛠️ Changes Implemented

### 1. SDK Installation & Setup
* Added `firebase_analytics: ^10.8.0` dependency to [pubspec.yaml](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/pubspec.yaml).
* Synchronized project packages via `flutter pub get`.

### 2. Analytics Service Class
* Created **`analytics_service.dart`** under `lib/services/` to wrap `FirebaseAnalytics` instance API.
* Implemented specific log hooks for the 7 required events:
  * `logLogin()`
  * `logLogout()`
  * `logSearchTopic(String keyword)`
  * `logViewPublication(String title, int year)`
  * `logViewJournal(String journalName)` (stubbed for future views)
  * `logViewKeyword(String keyword)` (stubbed for future views)
  * `logExportPdf(String topic)` (stubbed for future views)

### 3. Application ViewModel Hooks
* **`auth_viewmodel.dart`**: Injected `AnalyticsService`. Added `logLogin()` trigger inside Google Sign-In authentication wrapper and `logLogout()` inside session termination wrapper.
* **`search_viewmodel.dart`**: Injected `AnalyticsService`. Added `logSearchTopic(keyword)` trigger when initiating the OpenAlex works query.

### 4. UI Page Trigger
* **`detail_screen.dart`**: Reconfigured the screen widget from a `StatelessWidget` to a `StatefulWidget` to hook page entry events. Instantiated `AnalyticsService` via GetIt dependency container inside `initState()` and triggered `logViewPublication(title, year)` once the page mounts.

### 5. Dependency Injection
* Updated [injection_container.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/injection_container.dart) to register `AnalyticsService` lazy singleton and updated `SearchViewModel` and `AuthViewModel` factory initializers to receive the injected service.

---

## ✅ Verification & Validation Results

### 1. Code Quality & Lints
Ran `flutter analyze`:
* **Result**: **0 codebase errors!**

### 2. Unit Tests
Ran `flutter test`:
* **Result**: **All tests passed!**

```bash
00:00 +4: All tests passed!
```
