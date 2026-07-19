import 'package:kaido_data/models/point.dart';
import 'package:kaido_data/providers/kaido_config_provider.dart';
import 'package:kaido_data/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'points_provider.g.dart';

/// Index of [Point]s by their ID for O(1) lookup.
@riverpod
Map<String, Point> pointsById(Ref ref) {
  final points = ref.watch(pointsProvider).value;
  if (points == null) return const <String, Point>{};
  return {for (final p in points) p.id: p};
}

/// Manages fetching and caching of [Point] data for the current app.
@riverpod
class Points extends _$Points {
  // refresh() 経由の build() 実行だけリモートを強制するための一時フラグ。
  var _forceRemote = false;

  @override
  Future<List<Point>> build() async {
    final config = ref.watch(kaidoConfigProvider);
    final repo = ref.watch(pointRepositoryProvider);
    final forceRemote = _forceRemote;
    _forceRemote = false;
    return repo.getPoints(config.apiContext, forceRemote: forceRemote);
  }

  /// Refreshes the points data from the remote API, re-running [build].
  Future<void> refresh() async {
    _forceRemote = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
