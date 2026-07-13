import 'package:dio/dio.dart';

/// Attaches a `Bearer` authorization header to every outgoing request.
///
/// The token itself is not stored; it is resolved lazily via
/// [tokenProvider] on each request so that callers can rotate tokens
/// without recreating the interceptor.
class AuthInterceptor extends Interceptor {
  /// Creates an [AuthInterceptor] that resolves the bearer token via
  /// [tokenProvider].
  AuthInterceptor(this.tokenProvider);

  /// Callback returning the current auth token.
  final String Function() tokenProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = tokenProvider();
    options.headers['X-API-Key'] = token;
    handler.next(options);
  }
}
