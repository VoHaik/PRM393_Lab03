import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  static Future<ApiClient> create() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: ApiConstants.headers,
      ),
    );

    if (kIsWeb) {
      final cacheOptions = CacheOptions(
        store: MemCacheStore(),
        policy: CachePolicy.request,
        maxStale: const Duration(days: 7),
      );
      dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    } else {
      try {
        final cacheDir = await getApplicationDocumentsDirectory();
        final cacheStore = HiveCacheStore('${cacheDir.path}/openalex_cache');
        
        final cacheOptions = CacheOptions(
          store: cacheStore,
          policy: CachePolicy.request,
          hitCacheOnErrorExcept: [401, 403, 404],
          maxStale: const Duration(days: 7),
          priority: CachePriority.normal,
          keyBuilder: CacheOptions.defaultCacheKeyBuilder,
          allowPostMethod: false,
        );

        dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
      } catch (e) {
        // Fallback to memory cache store if path_provider or hive fails (e.g. in test environment)
        final cacheOptions = CacheOptions(
          store: MemCacheStore(),
          policy: CachePolicy.request,
          maxStale: const Duration(days: 7),
        );
        dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
      }
    }

    // Add logger interceptor for debugging in development
    dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseHeader: false,
      requestBody: false,
      responseBody: false,
      error: true,
    ));

    return ApiClient(dio);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Unknown network error');
    }
  }
}
