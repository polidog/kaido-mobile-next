import 'package:dio/dio.dart';

import 'package:kaido_api/endpoints/kaido_api_client.dart';
import 'package:kaido_api/interceptors/auth_interceptor.dart';
import 'package:kaido_api/interceptors/logging_interceptor.dart';
import 'package:kaido_api/interceptors/retry_interceptor.dart';
import 'package:kaido_api/models/detour_dto.dart';
import 'package:kaido_api/models/route_point_dto.dart';
import 'package:kaido_api/models/spot_dto.dart';
import 'package:kaido_api/result.dart';

/// Configuration for the Kaido API client.
class KaidoApiConfig {
  /// Creates a [KaidoApiConfig].
  const KaidoApiConfig({
    required this.baseUrl,
    required this.tokenProvider,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 15),
    this.sendTimeout = const Duration(seconds: 15),
  });

  /// Base URL of the `kaido-web-next` API.
  final String baseUrl;

  /// Callback returning the current bearer auth token.
  final String Function() tokenProvider;

  /// Connection timeout.
  final Duration connectTimeout;

  /// Receive timeout.
  final Duration receiveTimeout;

  /// Send timeout.
  final Duration sendTimeout;
}

/// Creates a [Dio] instance configured with [config] and the standard
/// Kaido interceptor chain: auth -> logging -> retry.
Dio createKaidoDio(KaidoApiConfig config) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(config.tokenProvider),
    LoggingInterceptor(),
    createRetryInterceptor(dio),
  ]);

  return dio;
}

/// Facade over [KaidoApiClient] that converts responses and errors into
/// [ApiResult].
class KaidoApiService {
  /// Creates a [KaidoApiService].
  KaidoApiService(this._client);

  final KaidoApiClient _client;

  /// Fetches spots for the given [context].
  Future<ApiResult<List<SpotDto>>> getSpots(String context) async {
    try {
      final result = await _client.getSpots(context);
      return ApiSuccess(result);
    } on DioException catch (e, st) {
      return ApiFailure(e, st);
    } on Object catch (e, st) {
      return ApiFailure(e, st);
    }
  }

  /// Fetches route coordinates for the given [context].
  Future<ApiResult<List<RoutePointDto>>> getRoutes(String context) async {
    try {
      final result = await _client.getRoutes(context);
      return ApiSuccess(result);
    } on DioException catch (e, st) {
      return ApiFailure(e, st);
    } on Object catch (e, st) {
      return ApiFailure(e, st);
    }
  }

  /// Fetches detour route coordinates for the given [context].
  Future<ApiResult<List<DetourDto>>> getDetours(String context) async {
    try {
      final result = await _client.getDetours(context);
      return ApiSuccess(result);
    } on DioException catch (e, st) {
      return ApiFailure(e, st);
    } on Object catch (e, st) {
      return ApiFailure(e, st);
    }
  }
}
