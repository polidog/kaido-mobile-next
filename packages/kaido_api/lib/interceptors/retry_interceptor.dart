import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

/// Creates a [RetryInterceptor] configured for the Kaido API.
///
/// Retries up to 3 times with linearly increasing delays before giving up.
RetryInterceptor createRetryInterceptor(Dio dio) {
  return RetryInterceptor(
    dio: dio,
    // Explicit for clarity — matches the default but documents intent.
    // ignore: avoid_redundant_argument_values
    retries: 3,
    retryDelays: const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
  );
}
