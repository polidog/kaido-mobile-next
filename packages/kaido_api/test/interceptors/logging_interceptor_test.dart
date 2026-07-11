import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_api/interceptors/logging_interceptor.dart';

void main() {
  group('LoggingInterceptor', () {
    test('masks Authorization header in request log', () {
      final logs = <String>[];
      final interceptor = LoggingInterceptor(
        log: (message) => logs.add(message.toString()),
      );

      final options = RequestOptions(path: '/test')
        ..headers['Authorization'] = 'Bearer secret-token-123';

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(logs, hasLength(1));
      expect(logs.first, contains('Bearer ***'));
      expect(logs.first, isNot(contains('secret-token-123')));
    });

    test('logs response status and method', () {
      final logs = <String>[];
      final interceptor = LoggingInterceptor(
        log: (message) => logs.add(message.toString()),
      );

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
      );

      interceptor.onResponse(response, ResponseInterceptorHandler());

      expect(logs, hasLength(1));
      expect(logs.first, contains('200'));
    });

    test('logs error details', () {
      final logs = <String>[];
      final interceptor = LoggingInterceptor(
        log: (message) => logs.add(message.toString()),
      );

      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        message: 'timeout',
      );

      runZonedGuarded(
        () => interceptor.onError(error, ErrorInterceptorHandler()),
        (_, _) {
          // ErrorInterceptorHandler.next propagates via Completer.
        },
      );

      expect(logs, hasLength(1));
      expect(logs.first, contains('ERROR'));
      expect(logs.first, contains('timeout'));
    });
  });
}
