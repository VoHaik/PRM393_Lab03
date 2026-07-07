# 🗺️ Project Memory & Map

This file acts as the primary "knowledge base" for the Journal Trend Analyzer project. It maintains the current architectural structure, active dependencies, file responsibilities, and a log of completed plans, allowing any agent or developer to understand the codebase instantly.

---

## 📌 Codebase Overview

* **Current Branch:** `dev`
* **Current Architecture:** MVVM (Model-View-ViewModel)
* **State Management:** Provider (`provider` package with ChangeNotifiers)
* **Primary Features:** 
  * Real-time academic publication and trend analysis using the OpenAlex API. Offline caching with Dio + Hive.
  * User Authentication using Firebase Authentication with Google Sign-In and routing guards.
  * User activity event tracking using Firebase Analytics.
  * **Automatic Rate Limit Resiliency:** Implemented custom Dio interceptors (`RetryOnRateLimitInterceptor`) with Exponential Backoff and jitter, plus spaced request delays to prevent and recover from HTTP 429 rate limit errors.

---

## 📁 Folder Structure & File Map

### Current Layout (Post-Migration + Firebase Auth & Analytics)

* **`lib/models/` (Data Structures & Serialization)**
  * `publication.dart`: Represents a publication entity. Includes reconstruction algorithm for abstract inverted indices.
  * `author.dart`: Represents an author entity. Includes parser for affiliations.
  * `journal.dart`: Represents a journal/source entity.
  * `analytics_summary.dart`: Represents aggregated dashboard statistics.
* **`lib/services/` (Data Access Services)**
  * `openalex_service.dart`: Encapsulates all OpenAlex API HTTP requests, error mapping, and numerical analytics calculations.
  * `auth_service.dart`: Encapsulates Firebase Authentication and Google Sign-In SDK functions.
  * `analytics_service.dart`: Encapsulates Firebase Analytics event tracking functions.
* **`lib/viewmodels/` (Application State & Logic)**
  * `search_viewmodel.dart`: Coordinates user keyword searches and publication lists. Integrates search_topic event tracking.
  * `detail_viewmodel.dart`: Loads publication details and abstracts.
  * `analysis_viewmodel.dart`: Queries and holds statistics for line charts, author rankings, and keyword frequencies.
  * `dashboard_viewmodel.dart`: Manages numeric summary data and top contributing sources.
  * `auth_viewmodel.dart`: Manages session user states, loading states, and login/logout trigger events. Integrates login and logout event tracking.
* **`lib/screens/` (Views / UI Layouts)**
  * `login_screen.dart`: Gateway screen for user authentication using Google Account.
  * `search_screen.dart`: Main topic search input and publication results list. Uses staggered request delays to reduce API load spikes.
  * `analysis_screen.dart`: Carousel of charts (trend charts, top keywords, author rankings).
  * `dashboard_screen.dart`: Summary cards and top source lists.
  * `detail_screen.dart`: Single publication details (StatefulWidget) showing meta information and reconstructed abstract. Integrates view_publication event tracking.
  * `profile_screen.dart`: Shows signed-in user avatar/credentials, sign out, and placeholders for other Firebase SDK demos.
* **`lib/widgets/` (Reusable View Components)**
  * `main_shell.dart`: Navigation shell holding 4 navigation tabs (Search, Trends, Dashboard, Profile).
* **`lib/utils/` (Configurations, Themes, Routers & Helpers)**
  * `constants/api_constants.dart`: OpenAlex API URL and polite pool user-agent details.
  * `navigation/router.dart`: Router mapping using GoRouter. Includes Redirect Guard (requires authentication for access to app features).
  * `theme/app_theme.dart`: Neon orange light theme and design styles.
  * `network/api_client.dart`: Caching Dio network client wrapper using Hive store. Includes `RetryOnRateLimitInterceptor` to handle and recover from HTTP 429 errors.
  * `error/exceptions.dart`: Standard server/cache/network exception definitions.
  * `abstract_parser.dart`: OpenAlex inverted abstract index parser utility.
* **`build_apk.bat`** (Root folder)
  * Automation script to clean cache, get packages, and compile Release APK for Android on Windows.
* **`docs/plans/`**
  * Contains historical, current, and future implementation plans, tasks, and walkthroughs.

---

## 🛠️ Plan & Modification Log

This log lists all plans that have been proposed, are in progress, or are completed.

| ID | Plan Name | Target File | Status | Date |
| :--- | :--- | :--- | :---: | :--- |
| **01** | Refactoring to MVVM + Provider | [01_migration_to_mvvm_provider_plan.md](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/docs/plans/01_migration_to_mvvm_provider_plan.md) | **Completed** | 2026-07-07 |
| **02** | Firebase Authentication Integration | [02_firebase_authentication_plan.md](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/docs/plans/02_firebase_authentication_plan.md) | **Completed** | 2026-07-07 |
| **03** | Firebase Analytics Integration | [03_firebase_analytics_plan.md](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/docs/plans/03_firebase_analytics_plan.md) | **Completed** | 2026-07-07 |

---

## 📋 Active Implementation State

Firebase Authentication (Google Sign-In) and Firebase Analytics are 100% integrated. The project features redirection guards and logs 7 required activity events. The code is error-free under `flutter analyze` and all unit tests pass successfully.
A `build_apk.bat` automation helper script is added at the root. Android application display name and Web tab headers are corrected to `Journal Trend Analyzer` for display compatibility.
The API client features a rate-limit retry mechanism to automatically resolve HTTP 429 errors.

Next steps will involve:
1. Setting up **Firebase Storage** for PDF report export.
2. Implementing the remaining required views (Journal List, Journal Detail, Keyword Detail).
3. Writing E2E integration test scripts using the **Patrol** testing framework.
