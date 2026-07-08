import 'package:get_it/get_it.dart';
import 'utils/network/api_client.dart';
import 'utils/app_config.dart';
import 'services/openalex_service.dart';
import 'services/auth_service.dart';
import 'services/analytics_service.dart';
import 'services/report_service.dart';
import 'services/storage_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/detail_viewmodel.dart';
import 'viewmodels/analysis_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/keyword_viewmodel.dart';
import 'viewmodels/journal_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init(AppConfig config) async {
  // --- ViewModels ---
  sl.registerFactory(
      () => SearchViewModel(openAlexService: sl(), analyticsService: sl()));
  sl.registerFactory(() => DetailViewModel(openAlexService: sl()));
  sl.registerFactory(() => AnalysisViewModel(openAlexService: sl()));
  sl.registerFactory(() => DashboardViewModel(openAlexService: sl()));
  sl.registerFactory(() => KeywordViewModel(openAlexService: sl()));
  sl.registerFactory(
      () => AuthViewModel(authService: sl(), analyticsService: sl()));
  sl.registerFactory(
      () => JournalViewModel(openAlexService: sl(), analyticsService: sl()));
  sl.registerFactory(
      () => ProfileViewModel(reportService: sl(), storageService: sl(), analyticsService: sl()));

  // --- Services ---
  sl.registerLazySingleton(() => OpenAlexService(apiClient: sl()));
  sl.registerLazySingleton(
      () => AuthService(webClientId: config.googleSignInWebClientId));
  sl.registerLazySingleton(() => AnalyticsService());
  sl.registerLazySingleton(() => ReportService());
  sl.registerLazySingleton(() => StorageService());

  // --- Core / External ---
  final apiClient = await ApiClient.create();
  sl.registerLazySingleton(() => apiClient);
}
