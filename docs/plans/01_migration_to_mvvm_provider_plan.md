# Migration to MVVM + Provider & Directory Reorganization

This implementation plan outlines the steps to refactor the Journal Trend Analyzer project from **Clean Architecture + BLoC** to **MVVM + Provider** and reorganize the directories to align with the Lab 03 specifications.

---

## User Review Required

> [!IMPORTANT]
> This migration is a major architectural refactoring that deletes existing BLoC state files, Use Cases, and Repositories, replacing them with Provider ViewModels, Service classes, and a simplified folder structure.

* **Package changes**: We will replace `flutter_bloc` with `provider`.
* **Structural restructuring**: Files under `lib/core/`, `lib/data/`, `lib/domain/`, and `lib/presentation/` will be moved into `lib/models/`, `lib/services/`, `lib/viewmodels/`, `lib/screens/`, `lib/widgets/`, and `lib/utils/`.

---

## Open Questions

> [!NOTE]
> Please confirm if you prefer **Provider** (as proposed below) or **Riverpod**. Provider is the industry-standard companion for classic MVVM in Flutter using `ChangeNotifier`.

---

## Proposed Changes

### Dependencies & Setup

#### [MODIFY] [pubspec.yaml](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/pubspec.yaml)
* Add `provider: ^6.1.2`.
* Remove `flutter_bloc` and `equatable`.

---

### 📂 Directory & Architecture Reorganization

We will reorganize the project from:
```
lib/
├── core/
├── data/
├── domain/
└── presentation/
```
to:
```
lib/
├── models/
├── services/
├── viewmodels/
├── screens/
├── widgets/
└── utils/
```

Here is the mapping of components:

| Original Path | New Path | Description |
| :--- | :--- | :--- |
| `lib/domain/entities/*` | `lib/models/*` | Combine domain entities and data models |
| `lib/data/models/*` | `lib/models/*` (Merged) | Merge JSON deserialization directly into the models |
| `lib/data/datasources/` & `lib/data/repositories/` | `lib/services/openalex_service.dart` | Consolidate data access into a direct service |
| `lib/presentation/bloc/*` | `lib/viewmodels/*_viewmodel.dart` | Rewrite BLoCs as `ChangeNotifier` ViewModels |
| `lib/presentation/screens/` | `lib/screens/` | Move screen widgets |
| `lib/presentation/widgets/` | `lib/widgets/` | Move reusable UI widgets |
| `lib/core/` (constants, navigation, theme, network, utils) | `lib/utils/` (constants, navigation, theme, network, utils) | Move boilerplate and configuration to utils |

---

### Component-by-Component Implementation

#### 1. Models Layer (`lib/models/`)

We will merge entities and models. Model serialization (`fromJson` / `toJson`) will live directly in the data models inside `lib/models/`.

* #### [NEW] [analytics_summary.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/models/analytics_summary.dart)
* #### [NEW] [author.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/models/author.dart)
* #### [NEW] [journal.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/models/journal.dart)
* #### [NEW] [publication.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/models/publication.dart)
* #### [DELETE] `lib/domain/entities/*`
* #### [DELETE] `lib/data/models/*`

#### 2. Services Layer (`lib/services/`)

We will combine data sources and repository implementations into `OpenAlexService`. We will also use `GetIt` or direct injection to instantiate `OpenAlexService`.

* #### [NEW] [openalex_service.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/services/openalex_service.dart)
* #### [DELETE] `lib/domain/repositories/*`
* #### [DELETE] `lib/domain/usecases/*`
* #### [DELETE] `lib/data/datasources/*`
* #### [DELETE] `lib/data/repositories/*`

#### 3. ViewModels Layer (`lib/viewmodels/`)

We will rewrite the BLoCs to `ChangeNotifier` classes. For example:
* `SearchViewModel` will expose `isLoading`, `errorMessage`, `publications`, `keyword` and have a `searchTopic(String keyword)` method.
* `DetailViewModel` will fetch and hold a `Publication` object details.
* `AnalysisViewModel` will manage publication trends and statistics charts state.
* `DashboardViewModel` will aggregate and hold `AnalyticsSummary` stats.

* #### [NEW] [search_viewmodel.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/viewmodels/search_viewmodel.dart)
* #### [NEW] [detail_viewmodel.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/viewmodels/detail_viewmodel.dart)
* #### [NEW] [analysis_viewmodel.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/viewmodels/analysis_viewmodel.dart)
* #### [NEW] [dashboard_viewmodel.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/viewmodels/dashboard_viewmodel.dart)
* #### [DELETE] `lib/presentation/bloc/*`

#### 4. Views & Screens (`lib/screens/` and `lib/widgets/`)

* Move screens and update state consumption from Bloc to Provider.
* Example: Replace `BlocBuilder<SearchBloc, SearchState>` with `Consumer<SearchViewModel>`.
* #### [NEW] Move all screens to `lib/screens/`
* #### [NEW] Move all widgets to `lib/widgets/`
* #### [DELETE] `lib/presentation/screens/*`
* #### [DELETE] `lib/presentation/widgets/*`

#### 5. Utils Layer (`lib/utils/`)

* #### [NEW] [api_client.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/utils/network/api_client.dart) (Moved from `lib/core/network/`)
* #### [NEW] [router.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/utils/navigation/router.dart) (Moved from `lib/core/navigation/` and updated imports)
* #### [NEW] [app_theme.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/utils/theme/app_theme.dart)
* #### [NEW] [api_constants.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/utils/constants/api_constants.dart)
* #### [NEW] [abstract_parser.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/utils/abstract_parser.dart)
* #### [DELETE] `lib/core/*`

#### 6. Bootstrapping

* #### [MODIFY] [injection_container.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/injection_container.dart)
  * Set up dependency injection for the services (`OpenAlexService` and `ApiClient`).
  * Register factory/singleton classes.
* #### [MODIFY] [main.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/main.dart)
  * Wrap `MaterialApp.router` with `MultiProvider` instead of `MultiBlocProvider`.
  * Register ViewModels (`SearchViewModel`, `DetailViewModel`, `AnalysisViewModel`, `DashboardViewModel`).

---

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure there are no compilation errors or linter warnings.
- Run `flutter test` to verify if there are any unit tests to run, or disable them/rewrite them if they depend on BLoC (unit tests can be adapted to test ViewModels).

### Manual Verification
- Run the Flutter application on Android Emulator.
- Search for a topic (e.g. *Artificial Intelligence*).
- Verify that results are displayed correctly on the Search tab.
- Click a publication to verify the Detail screen is displayed and the abstract is reconstructed correctly.
- Verify the Trends tab displays publication counts per year and keyword/author lists.
- Verify the Dashboard tab displays metrics and top author/journal details.
- Verify the bottom navigation remains smooth and responsive.
