import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_api/interceptors/retry_interceptor.dart';

void main() {
  group('createRetryInterceptor', () {
    test('creates a RetryInterceptor', () {
      final dio = Dio();
      final interceptor = createRetryInterceptor(dio);
      expect(interceptor, isA<RetryInterceptor>());
    });
  });
}
