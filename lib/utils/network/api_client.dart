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

    // Add automatic retry mechanism for HTTP 429 (Rate Limiting)
    dio.interceptors.add(RetryOnRateLimitInterceptor(
      dio: dio,
      maxRetries: 3,
      initialDelay: const Duration(milliseconds: 1000),
    ));

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

/// Custom Interceptor that catches HTTP 429 (Too Many Requests) rate limit responses
/// and retries the request using Exponential Backoff.
class RetryOnRateLimitInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;

  RetryOnRateLimitInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 1000),
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final response = err.response;
    final int retryCount = requestOptions.extra['retry_count'] ?? 0;

    // Retry only if response status is HTTP 429 and we haven't reached max retries
    if (response != null && response.statusCode == 429 && retryCount < maxRetries) {
      requestOptions.extra['retry_count'] = retryCount + 1;
      
      // Calculate delay with Exponential Backoff (1s, 2s, 4s...)
      final delay = initialDelay * (1 << retryCount);
      
      debugPrint('[API Client] HTTP 429 Rate Limited on ${requestOptions.uri}. '
          'Retrying in ${delay.inMilliseconds}ms (Attempt ${retryCount + 1}/$maxRetries)...');
      
      await Future.delayed(delay);
      
      try {
        // Fetch the request again
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      }
    }
    
    return handler.next(err);
  }
}
