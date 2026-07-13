# Firebase Analytics Integration Plan

This implementation plan describes the technical steps to integrate **Firebase Analytics** into the Journal Trend Analyzer project, establishing event tracking hooks for the 7 user activity events specified in Section 5 of the PDF documentation.

---

## User Review Required

> [!NOTE]
> Since the Firebase project setup is already complete and `google-services.json` is configured, adding Firebase Analytics does not require any manual setup on the Firebase Console. Events will automatically appear in your Firebase Analytics dashboard.

---

## Open Questions

> [!NOTE]
> For testing events in real-time, you can use the **Firebase DebugView** console. You may need to run `adb shell setprop debug.firebase.analytics.app com.example.journal_trend_analyzer` on your computer to enable debugging for Android.

---

## Proposed Changes

### Dependencies & Setup

#### [MODIFY] [pubspec.yaml](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/pubspec.yaml)
* Add dependency:
  * `firebase_analytics: ^10.8.0`

---

### Services Layer (`lib/services/`)

#### [NEW] [analytics_service.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/services/analytics_service.dart)
Create an analytics service class wrapping `FirebaseAnalytics` to encapsulate the 7 required events:

| Event Name | Method | Parameters | Description |
| :--- | :--- | :--- | :--- |
| **`login`** | `logLogin()` | None | User successfully logs in |
| **`logout`** | `logLogout()` | None | User logs out |
| **`search_topic`** | `logSearchTopic(String keyword)` | `keyword` | User searches a topic |
| **`view_publication`** | `logViewPublication(String title, int year)` | `publication_title`, `publication_year` | User opens details page |
| **`view_journal`** | `logViewJournal(String journalName)` | `journal_name` | User opens a journal detail page |
| **`view_keyword`** | `logViewKeyword(String keyword)` | `keyword` | User opens a keyword detail page |
| **`export_pdf`** | `logExportPdf(String topic)` | `topic` | User exports dashboard to PDF |

---

### Integration with ViewModels & Screens

#### [MODIFY] [auth_viewmodel.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/viewmodels/auth_viewmodel.dart)
* Inject `AnalyticsService`.
* Call `analyticsService.logLogin()` on successful login.
* Call `analyticsService.logLogout()` on logout.

#### [MODIFY] [search_viewmodel.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/viewmodels/search_viewmodel.dart)
* Inject `AnalyticsService`.
* Call `analyticsService.logSearchTopic(keyword)` on starting a search.

#### [MODIFY] [detail_screen.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/screens/detail_screen.dart)
* Convert `DetailScreen` from `StatelessWidget` to `StatefulWidget`.
* Inject `AnalyticsService` using `GetIt` or passing via router, and trigger `logViewPublication(publication.title, publication.publicationYear)` inside `initState()`.

---

### Bootstrapping & DI

#### [MODIFY] [injection_container.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/injection_container.dart)
* Register `AnalyticsService` as a lazy singleton.
* Inject `AnalyticsService` into the constructors of `AuthViewModel` and `SearchViewModel`.

---

## Verification Plan

### Automated Tests
* Run `flutter analyze` to ensure there are no syntax errors.

### Manual Verification
* Run the app on an Android emulator or Chrome.
* Perform Google Sign-In -> Verify `login` event.
* Search for a topic -> Verify `search_topic` event (with `keyword` parameter).
* Click on a publication -> Verify `view_publication` event (with `publication_title` and `publication_year` parameters).
* Click Sign Out -> Verify `logout` event.
* Monitor Firebase Console > Analytics > DebugView to confirm all events are received.
