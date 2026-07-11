import 'package:dio/dio.dart';
import 'package:kaido_api/kaido_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_service_providers.g.dart';

/// Provides the [KaidoApiConfig] used to build the Dio client.
///
/// The base URL and token are provisional and should be overridden by the
/// app with values injected via `--dart-define-from-file`.
@riverpod
KaidoApiConfig kaidoApiConfig(Ref ref) {
  return KaidoApiConfig(baseUrl: '', tokenProvider: () => '');
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
