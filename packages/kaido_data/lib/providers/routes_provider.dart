import 'package:kaido_data/models/route_point.dart';
import 'package:kaido_data/providers/kaido_config_provider.dart';
import 'package:kaido_data/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routes_provider.g.dart';

/// Manages fetching and caching of [RoutePoint] data for the current app.
@riverpod
class Routes extends _$Routes {
  @override
  Future<List<RoutePoint>> build() async {
    final config = ref.watch(kaidoConfigProvider);
    final repo = ref.watch(routeRepositoryProvider);
    return repo.getRoutes(config.apiContext);
  }

  /// Refreshes the routes data, re-running [build].
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
