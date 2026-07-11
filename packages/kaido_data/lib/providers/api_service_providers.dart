import 'package:dio/dio.dart';
import 'package:kaido_api/kaido_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_service_providers.g.dart';

/// Base URL of the `kaido-web-next` API, injected at build time via
/// `--dart-define-from-file`.
const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

/// Bearer token for the `kaido-web-next` API, injected at build time via
/// `--dart-define-from-file`.
const _apiToken = String.fromEnvironment('API_TOKEN');

/// Provides the [KaidoApiConfig] used to build the Dio client.
///
/// The base URL and token are read from `--dart-define-from-file` values
/// injected by the app at build time.
@riverpod
KaidoApiConfig kaidoApiConfig(Ref ref) {
  assert(_apiBaseUrl.isNotEmpty, 'API_BASE_URL must be set via --dart-define');
  assert(_apiToken.isNotEmpty, 'API_TOKEN must be set via --dart-define');
  return KaidoApiConfig(baseUrl: _apiBaseUrl, tokenProvider: () => _apiToken);
}

/// Provides the shared [Dio] instance configured with the standard Kaido
/// interceptor chain.
@riverpod
Dio dio(Ref ref) {
  final config = ref.watch(kaidoApiConfigProvider);
  return createKaidoDio(config);
}

/// Provides the [KaidoApiClient] backed by [dioProvider].
@riverpod
KaidoApiClient kaidoApiClient(Ref ref) {
  return KaidoApiClient(ref.watch(dioProvider));
}

/// Provides the [KaidoApiService] facade over [kaidoApiClientProvider].
@riverpod
KaidoApiService kaidoApiService(Ref ref) {
  return KaidoApiService(ref.watch(kaidoApiClientProvider));
}
