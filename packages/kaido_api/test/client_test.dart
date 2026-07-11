import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_api/client.dart';
import 'package:kaido_api/interceptors/auth_interceptor.dart';
import 'package:kaido_api/interceptors/logging_interceptor.dart';

void main() {
  group('createKaidoDio', () {
    late Dio dio;

    setUp(() {
      dio = createKaidoDio(
        KaidoApiConfig(
          baseUrl: 'https://example.com',
          tokenProvider: () => 'tok',
        ),
      );
    });

    test('sets baseUrl', () {
      expect(dio.options.baseUrl, 'https://example.com');
    });

    test('sets timeouts', () {
      expect(dio.options.connectTimeout, const Duration(seconds: 10));
      expect(dio.options.receiveTimeout, const Duration(seconds: 15));
      expect(dio.options.sendTimeout, const Duration(seconds: 15));
    });

    test('registers interceptors in correct order', () {
      expect(dio.interceptors.whereType<AuthInterceptor>(), hasLength(1));
      expect(dio.interceptors.whereType<LoggingInterceptor>(), hasLength(1));
      expect(dio.interceptors.whereType<RetryInterceptor>(), hasLength(1));

      final authIdx = dio.interceptors
          .indexWhere((i) => i is AuthInterceptor);
      final loggingIdx = dio.interceptors
          .indexWhere((i) => i is LoggingInterceptor);
      final retryIdx = dio.interceptors
          .indexWhere((i) => i is RetryInterceptor);
      expect(authIdx, lessThan(loggingIdx));
      expect(loggingIdx, lessThan(retryIdx));
    });
  });

  group('KaidoApiConfig', () {
    test('uses custom timeouts', () {
      final config = KaidoApiConfig(
        baseUrl: 'https://example.com',
        tokenProvider: () => 'tok',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
      );

      final dio = createKaidoDio(config);
      expect(dio.options.connectTimeout, const Duration(seconds: 5));
      expect(dio.options.receiveTimeout, const Duration(seconds: 5));
      expect(dio.options.sendTimeout, const Duration(seconds: 5));
    });
  });
}
