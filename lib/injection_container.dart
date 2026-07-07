import 'package:get_it/get_it.dart';
import 'utils/network/api_client.dart';
import 'services/openalex_service.dart';
import 'services/auth_service.dart';
import 'services/analytics_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/detail_viewmodel.dart';
import 'viewmodels/analysis_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- ViewModels ---
  sl.registerFactory(() => SearchViewModel(openAlexService: sl(), analyticsService: sl()));
  sl.registerFactory(() => DetailViewModel(openAlexService: sl()));
  sl.registerFactory(() => AnalysisViewModel(openAlexService: sl()));
  sl.registerFactory(() => DashboardViewModel(openAlexService: sl()));
  sl.registerFactory(() => AuthViewModel(authService: sl(), analyticsService: sl()));

  // --- Services ---
  sl.registerLazySingleton(() => OpenAlexService(apiClient: sl()));
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => AnalyticsService());

  // --- Core / External ---
  final apiClient = await ApiClient.create();
  sl.registerLazySingleton(() => apiClient);
}
