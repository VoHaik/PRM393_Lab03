# Tasks - Migration to MVVM + Provider

- [x] Add `provider` dependency and clean up `flutter_bloc` / `equatable`
- [x] Create new folder structure under `lib/`
- [x] Migrate models & JSON serialization to `lib/models/`
- [x] Consolidate data clients and remote datasources to `lib/services/openalex_service.dart`
- [x] Migrate core utilities (constants, router, theme, network client) to `lib/utils/`
- [x] Convert BLoCs to ChangeNotifier ViewModels in `lib/viewmodels/`
  - [x] `SearchViewModel`
  - [x] `DetailViewModel`
  - [x] `AnalysisViewModel`
  - [x] `DashboardViewModel`
- [x] Convert UI Screens to use Provider (under `lib/screens/` and `lib/widgets/`)
  - [x] `SearchScreen`
  - [x] `DetailScreen`
  - [x] `AnalysisScreen`
  - [x] `DashboardScreen`
- [x] Update `lib/injection_container.dart` and `lib/main.dart`
- [x] Clean up and delete old directories (`lib/core/`, `lib/data/`, `lib/domain/`, `lib/presentation/`)
- [x] Verify build correctness (`flutter analyze`)
