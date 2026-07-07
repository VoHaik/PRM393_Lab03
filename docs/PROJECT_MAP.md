# 🗺️ Project Memory & Map

This file acts as the primary "knowledge base" for the Journal Trend Analyzer project. It maintains the current architectural structure, active dependencies, file responsibilities, and a log of completed plans, allowing any agent or developer to understand the codebase instantly.

---

## 📌 Codebase Overview

* **Current Branch:** `dev`
* **Current Architecture:** MVVM (Model-View-ViewModel)
* **State Management:** Provider (`provider` package with ChangeNotifiers)
* **Primary Features:** Real-time academic publication and trend analysis using the OpenAlex API. Offline caching with Dio + Hive.

---

## 📁 Folder Structure & File Map

### Current Layout (Post-Migration)

* **`lib/models/` (Data Structures & Serialization)**
  * `publication.dart`: Represents a publication entity. Includes reconstruction algorithm for abstract inverted indices.
  * `author.dart`: Represents an author entity. Includes parser for affiliations.
  * `journal.dart`: Represents a journal/source entity.
  * `analytics_summary.dart`: Represents aggregated dashboard statistics.
* **`lib/services/` (Data Access Services)**
  * `openalex_service.dart`: Encapsulates all OpenAlex API HTTP requests, error mapping, and numerical analytics calculations.
* **`lib/viewmodels/` (Application State & Logic)**
  * `search_viewmodel.dart`: Coordinates user keyword searches and publication lists.
  * `detail_viewmodel.dart`: Loads publication details and abstracts.
  * `analysis_viewmodel.dart`: Queries and holds statistics for line charts, author rankings, and keyword frequencies.
  * `dashboard_viewmodel.dart`: Manages numeric summary data and top contributing sources.
* **`lib/screens/` (Views / UI Layouts)**
  * `search_screen.dart`: Main topic search input and publication results list.
  * `analysis_screen.dart`: Carousel of charts (trend charts, top keywords, author rankings).
  * `dashboard_screen.dart`: Summary cards and top source lists.
  * `detail_screen.dart`: Single publication meta information and reconstructed abstract.
* **`lib/widgets/` (Reusable View Components)**
  * `main_shell.dart`: Navigation shell holding the bottom navigation bar.
* **`lib/utils/` (Configurations, Themes, Routers & Helpers)**
  * `constants/api_constants.dart`: OpenAlex API URL and polite pool user-agent details.
  * `navigation/router.dart`: Router mapping using GoRouter.
  * `theme/app_theme.dart`: Neon orange light theme and design styles.
  * `network/api_client.dart`: Caching Dio network client wrapper using Hive store.
  * `error/exceptions.dart`: Standard server/cache/network exception definitions.
  * `abstract_parser.dart`: OpenAlex inverted abstract index parser utility.
* **`docs/plans/`**
  * Contains historical, current, and future implementation plans, tasks, and walkthroughs.

---

## 🛠️ Plan & Modification Log

This log lists all plans that have been proposed, are in progress, or are completed.

| ID | Plan Name | Target File | Status | Date |
| :--- | :--- | :--- | :---: | :--- |
| **01** | Refactoring to MVVM + Provider | [01_migration_to_mvvm_provider_plan.md](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/docs/plans/01_migration_to_mvvm_provider_plan.md) | **Completed** | 2026-07-07 |

---

## 📋 Active Implementation State

All code is fully migrated to **MVVM + Provider** architecture. The codebase is clean (`flutter analyze` has 0 errors) and all tests (`flutter test`) pass successfully.
Next phases will involve:
1. Setting up **Firebase Services** (Authentication, Storage, FCM, Analytics, Crashlytics, Remote Config).
2. Implementing the remaining 4 required screens (Login, Journal List, Journal Detail, Keyword Detail, Profile) to reach the 8-screen requirement.
3. Writing E2E integration test scripts using the **Patrol** testing framework.
