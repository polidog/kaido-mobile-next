import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_api/interceptors/auth_interceptor.dart';

void main() {
  group('AuthInterceptor', () {
    test('adds Authorization header on request', () {
      final interceptor = AuthInterceptor(() => 'test-token');
      final options = RequestOptions(path: '/test');

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers['Authorization'], 'Bearer test-token');
    });

    test('resolves token lazily via provider', () {
      var callCount = 0;
      final interceptor = AuthInterceptor(() {
        callCount++;
        return 'token-$callCount';
      });

      final options1 = RequestOptions(path: '/a');
      interceptor.onRequest(options1, RequestInterceptorHandler());
      expect(options1.headers['Authorization'], 'Bearer token-1');

      final options2 = RequestOptions(path: '/b');
      interceptor.onRequest(options2, RequestInterceptorHandler());
      expect(options2.headers['Authorization'], 'Bearer token-2');
    });
  });
}
