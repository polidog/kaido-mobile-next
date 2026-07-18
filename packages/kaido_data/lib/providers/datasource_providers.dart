import 'package:kaido_data/datasources/asset_loader.dart';
import 'package:kaido_data/datasources/file_cache_data_source.dart';
import 'package:kaido_data/datasources/local_bundle_data_source.dart';
import 'package:kaido_data/datasources/remote/detours_remote_data_source.dart';
import 'package:kaido_data/datasources/remote/points_remote_data_source.dart';
import 'package:kaido_data/datasources/remote/routes_remote_data_source.dart';
import 'package:kaido_data/datasources/turso/turso_data_sources.dart';
import 'package:kaido_data/datasources/turso/turso_map_database.dart';
import 'package:kaido_data/providers/api_service_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'datasource_providers.g.dart';

/// Read-only auth token for the Turso databases, injected at build time via
/// `--dart-define-from-file`.
const _tursoAuthToken = String.fromEnvironment('TURSO_AUTH_TOKEN');

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

/// Provides the [TursoSettings] built from `--dart-define` values.
@riverpod
TursoSettings tursoSettings(Ref ref) {
  // assert はリリースビルドで無効化されるため、後段の libsql 認証エラー
  // ではなく起動直後に原因が分かるよう実行時チェックにする。
  if (_tursoAuthToken.isEmpty) {
    throw StateError('TURSO_AUTH_TOKEN must be set via --dart-define');
  }
  return const TursoSettings(authToken: _tursoAuthToken);
}

/// Provides the [TursoMapDatabase] managing the embedded replica.
///
/// Kept alive so the replica connection survives provider rebuilds.
@Riverpod(keepAlive: true)
TursoMapDatabase tursoMapDatabase(Ref ref) {
  final database = TursoMapDatabase(
    apiService: ref.watch(kaidoApiServiceProvider),
    settings: ref.watch(tursoSettingsProvider),
  );
  ref.onDispose(database.dispose);
  return database;
}

/// Provides the [PointsRemoteDataSource] backed by the Turso replica.
@riverpod
PointsRemoteDataSource pointsRemoteDataSource(Ref ref) {
  return TursoPointsDataSource(ref.watch(tursoMapDatabaseProvider));
}

/// Provides the [RoutesRemoteDataSource] backed by the Turso replica.
@riverpod
RoutesRemoteDataSource routesRemoteDataSource(Ref ref) {
  return TursoRoutesDataSource(ref.watch(tursoMapDatabaseProvider));
}

/// Provides the [DetoursRemoteDataSource] backed by the Turso replica.
@riverpod
DetoursRemoteDataSource detoursRemoteDataSource(Ref ref) {
  return TursoDetoursDataSource(ref.watch(tursoMapDatabaseProvider));
}
