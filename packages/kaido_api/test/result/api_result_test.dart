import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_api/result.dart';

void main() {
  group('ApiResult', () {
    test('ApiSuccess holds data', () {
      const result = ApiSuccess<int>(42);
      expect(result.data, 42);
    });

    test('ApiFailure holds error and stackTrace', () {
      final trace = StackTrace.current;
      final result = ApiFailure<int>(Exception('oops'), trace);
      expect(result.error, isA<Exception>());
      expect(result.stackTrace, trace);
    });

    test('ApiFailure stackTrace defaults to null', () {
      const result = ApiFailure<int>('error');
      expect(result.stackTrace, isNull);
    });

    test('pattern match covers both cases', () {
      const ApiResult<int> success = ApiSuccess<int>(1);
      const ApiResult<int> failure = ApiFailure<int>('err');

      final successValue = switch (success) {
        ApiSuccess(:final data) => data,
        ApiFailure() => -1,
      };
      expect(successValue, 1);

      final failureValue = switch (failure) {
        ApiSuccess(:final data) => data,
        ApiFailure() => -1,
      };
      expect(failureValue, -1);
    });
  });
}
