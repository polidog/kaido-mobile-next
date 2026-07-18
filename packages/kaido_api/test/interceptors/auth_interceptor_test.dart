import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_api/interceptors/auth_interceptor.dart';

void main() {
  group('AuthInterceptor', () {
    test('adds X-API-Key header on request', () {
      final interceptor = AuthInterceptor(() => 'test-token');
      final options = RequestOptions(path: '/test');

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers['X-API-Key'], 'test-token');
    });

    test('resolves token lazily via provider', () {
      var callCount = 0;
      final interceptor = AuthInterceptor(() {
        callCount++;
        return 'token-$callCount';
      });

      final options1 = RequestOptions(path: '/a');
      interceptor.onRequest(options1, RequestInterceptorHandler());
      expect(options1.headers['X-API-Key'], 'token-1');

      final options2 = RequestOptions(path: '/b');
      interceptor.onRequest(options2, RequestInterceptorHandler());
      expect(options2.headers['X-API-Key'], 'token-2');
    });
  });
}
