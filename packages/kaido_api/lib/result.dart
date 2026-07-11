/// Result type for API operations.
///
/// Mirrors the Result型パターン used by `kaido-web-next` so that callers can
/// exhaustively pattern-match on success/failure without throwing.
sealed class ApiResult<T> {
  const ApiResult();
}

/// A successful API call, carrying the decoded [data].
final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  /// The successfully decoded response payload.
  final T data;
}

/// A failed API call, carrying the [error] and optional [stackTrace].
final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.error, [this.stackTrace]);

  /// The error that caused the failure.
  final Object error;

  /// The stack trace captured at the point of failure, if available.
  final StackTrace? stackTrace;
}
