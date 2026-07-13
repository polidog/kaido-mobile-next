import 'package:kaido_data/models/route_point.dart';
import 'package:kaido_data/providers/kaido_config_provider.dart';
import 'package:kaido_data/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routes_provider.g.dart';

/// Manages fetching and caching of [RoutePoint] data for the current app.
@riverpod
class Routes extends _$Routes {
  // refresh() 経由の build() 実行だけリモートを強制するための一時フラグ。
  var _forceRemote = false;

  @override
  Future<List<RoutePoint>> build() async {
    final config = ref.watch(kaidoConfigProvider);
    final repo = ref.watch(routeRepositoryProvider);
    final forceRemote = _forceRemote;
    _forceRemote = false;
    return repo.getRoutes(config.apiContext, forceRemote: forceRemote);
  }

  /// Refreshes the routes data from the remote API, re-running [build].
  Future<void> refresh() async {
    _forceRemote = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
