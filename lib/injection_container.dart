import 'package:get_it/get_it.dart';
import 'utils/network/api_client.dart';
import 'services/openalex_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/detail_viewmodel.dart';
import 'viewmodels/analysis_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- ViewModels ---
  sl.registerFactory(() => SearchViewModel(openAlexService: sl()));
  sl.registerFactory(() => DetailViewModel(openAlexService: sl()));
  sl.registerFactory(() => AnalysisViewModel(openAlexService: sl()));
  sl.registerFactory(() => DashboardViewModel(openAlexService: sl()));

  // --- Services ---
  sl.registerLazySingleton(() => OpenAlexService(apiClient: sl()));

  // --- Core / External ---
  final apiClient = await ApiClient.create();
  sl.registerLazySingleton(() => apiClient);
}
