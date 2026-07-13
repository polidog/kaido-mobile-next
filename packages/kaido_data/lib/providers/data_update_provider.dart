import 'package:kaido_data/providers/detours_provider.dart';
import 'package:kaido_data/providers/points_provider.dart';
import 'package:kaido_data/providers/routes_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_update_provider.g.dart';

/// Runs a full data update (points, routes, detours) when first listened
/// to.
///
/// The state is `loading` while the update is running, `data` once all
/// three refreshes completed, and `error` when any of them failed.
/// Invalidate this provider to run the update again.
@riverpod
class DataUpdate extends _$DataUpdate {
  @override
  Future<void> build() async {
    // Providers may not modify other providers during their (synchronous)
    // initialization, so defer the refreshes by one microtask.
    await null;
    // 3 つのリフレッシュに相互依存はないため並列に実行する。エラーは各
    // provider の state に guard されるので Future.wait は失敗しない。
    await Future.wait([
      ref.read(pointsProvider.notifier).refresh(),
      ref.read(routesProvider.notifier).refresh(),
      ref.read(detoursProvider.notifier).refresh(),
    ]);
    _throwIfFailed(ref.read(pointsProvider));
    _throwIfFailed(ref.read(routesProvider));
    _throwIfFailed(ref.read(detoursProvider));
  }

  /// Rethrows the error held by [value], if any.
  ///
  /// The individual providers guard their own errors into their state, so
  /// they are surfaced here to fail the update as a whole.
  void _throwIfFailed(AsyncValue<Object?> value) {
    final error = value.error;
    if (error != null) {
      Error.throwWithStackTrace(
        error,
        value.stackTrace ?? StackTrace.current,
      );
    }
  }
}
