import 'package:kaido_data/providers/datasource_providers.dart';
import 'package:kaido_data/providers/kaido_config_provider.dart';
import 'package:kaido_data/repositories/detour_repository.dart';
import 'package:kaido_data/repositories/point_repository.dart';
import 'package:kaido_data/repositories/route_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

/// Provides the [PointRepository] for the current app.
@riverpod
PointRepository pointRepository(Ref ref) {
  final config = ref.watch(kaidoConfigProvider);
  return PointRepository(
    remote: ref.watch(pointsRemoteDataSourceProvider),
    fileCache: ref.watch(fileCacheDataSourceProvider),
    bundle: ref.watch(localBundleDataSourceProvider),
    assetPrefix: config.assetPrefix,
  );
}

/// Provides the [RouteRepository] for the current app.
@riverpod
RouteRepository routeRepository(Ref ref) {
  final config = ref.watch(kaidoConfigProvider);
  return RouteRepository(
    remote: ref.watch(routesRemoteDataSourceProvider),
    fileCache: ref.watch(fileCacheDataSourceProvider),
    bundle: ref.watch(localBundleDataSourceProvider),
    assetPrefix: config.assetPrefix,
  );
}

/// Provides the [DetourRepository] for the current app.
@riverpod
DetourRepository detourRepository(Ref ref) {
  final config = ref.watch(kaidoConfigProvider);
  return DetourRepository(
    remote: ref.watch(detoursRemoteDataSourceProvider),
    fileCache: ref.watch(fileCacheDataSourceProvider),
    bundle: ref.watch(localBundleDataSourceProvider),
    assetPrefix: config.assetPrefix,
  );
}
