import 'package:dio/dio.dart';

/// Logs outgoing requests, incoming responses, and errors.
///
/// The `Authorization` header value is masked as `Bearer ***` so that
/// tokens never appear in logs. The log sink is injectable so callers can
/// route output to their logging framework of choice.
class LoggingInterceptor extends Interceptor {
  /// Creates a [LoggingInterceptor].
  LoggingInterceptor({void Function(Object message)? log})
    : _log = log ?? _defaultLog;

  final void Function(Object message) _log;

  static void _defaultLog(Object message) {
    // Default log sink when no custom logger is provided.
    // ignore: avoid_print
    print(message);
  }

  Map<String, dynamic> _maskHeaders(Map<String, dynamic> headers) {
    final masked = Map<String, dynamic>.from(headers);
    if (masked.containsKey('Authorization')) {
      masked['Authorization'] = 'Bearer ***';
    }
    return masked;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _log(
      '--> ${options.method} ${options.uri} '
      'headers=${_maskHeaders(options.headers)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(
      '<-- ${response.statusCode} '
      '${response.requestOptions.method} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    _log(
      '<-- ERROR ${err.requestOptions.method} '
      '${err.requestOptions.uri}: ${err.message}',
    );
    handler.next(err);
  }
}
