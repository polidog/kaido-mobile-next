import 'package:kaido_data/datasources/asset_loader.dart';
import 'package:kaido_data/datasources/file_cache_data_source.dart';
import 'package:kaido_data/datasources/local_bundle_data_source.dart';
import 'package:kaido_data/datasources/remote/detours_remote_data_source.dart';
import 'package:kaido_data/datasources/remote/points_remote_data_source.dart';
import 'package:kaido_data/datasources/remote/routes_remote_data_source.dart';
import 'package:kaido_data/providers/api_service_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'datasource_providers.g.dart';

/// Provides the [AssetLoader] used to read bundled JSON fallback data.
@riverpod
AssetLoader assetLoader(Ref ref) => const RootBundleAssetLoader();

/// Provides the [FileCacheDataSource] used to persist fetched data locally.
@riverpod
FileCacheDataSource fileCacheDataSource(Ref ref) => FileCacheDataSource();

/// Provides the [LocalBundleDataSource] used to load fallback JSON assets.
@riverpod
LocalBundleDataSource localBundleDataSource(Ref ref) {
  return LocalBundleDataSource(ref.watch(assetLoaderProvider));
}

/// Provides the [PointsRemoteDataSource] used to fetch points from the API.
@riverpod
PointsRemoteDataSource pointsRemoteDataSource(Ref ref) {
  return ApiPointsRemoteDataSource(ref.watch(kaidoApiServiceProvider));
}

/// Provides the [RoutesRemoteDataSource] used to fetch routes from the API.
@riverpod
RoutesRemoteDataSource routesRemoteDataSource(Ref ref) {
  return ApiRoutesRemoteDataSource(ref.watch(kaidoApiServiceProvider));
}

/// Provides the [DetoursRemoteDataSource] used to fetch detours from the
/// API.
@riverpod
DetoursRemoteDataSource detoursRemoteDataSource(Ref ref) {
  return ApiDetoursRemoteDataSource(ref.watch(kaidoApiServiceProvider));
}
