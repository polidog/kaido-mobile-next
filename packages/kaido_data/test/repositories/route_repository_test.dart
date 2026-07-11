import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/datasources/asset_loader.dart';
import 'package:kaido_data/datasources/file_cache_data_source.dart';
import 'package:kaido_data/datasources/local_bundle_data_source.dart';
import 'package:kaido_data/models/route_point.dart';
import 'package:kaido_data/repositories/route_repository.dart';

import '../helpers/fake_asset_loader.dart';
import '../helpers/fake_remote_data_sources.dart';

void main() {
  late Directory tempDir;
  late FileCacheDataSource fileCache;

  const bundledRoutes = [RoutePoint(id: 99, lat: 0, lng: 0)];
  const remoteRoutes = [RoutePoint(id: 1, lat: 1, lng: 2)];
  const cachedRoutes = [RoutePoint(id: 2, lat: 3, lng: 4)];

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('route_repo_test');
    fileCache = FileCacheDataSource(directoryResolver: () async => tempDir);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  LocalBundleDataSource bundleDataSource() {
    final AssetLoader loader = FakeAssetLoader({
      'assets/json/routes.json': '[{"id": 99, "lat": 0.0, "lng": 0.0}]',
    });
    return LocalBundleDataSource(loader);
  }

  test('API success returns data and writes to cache', () async {
    final repo = RouteRepository(
      remote: FakeRoutesRemoteDataSource(const ApiSuccess(remoteRoutes)),
      fileCache: fileCache,
      bundle: bundleDataSource(),
      assetPrefix: 'assets',
    );

    final result = await repo.getRoutes('tokaido');

    expect(result, remoteRoutes);
    final cached = await fileCache.readRoutes('tokaido');
    expect(cached, remoteRoutes);
  });

  test('API failure with existing cache returns cached data', () async {
    await fileCache.cacheRoutes('tokaido', cachedRoutes);

    final repo = RouteRepository(
      remote: FakeRoutesRemoteDataSource(
        ApiFailure(Exception('network error')),
      ),
      fileCache: fileCache,
      bundle: bundleDataSource(),
      assetPrefix: 'assets',
    );

    final result = await repo.getRoutes('tokaido');

    expect(result, cachedRoutes);
  });

  test('API failure with no cache falls back to bundled JSON', () async {
    final repo = RouteRepository(
      remote: FakeRoutesRemoteDataSource(
        ApiFailure(Exception('network error')),
      ),
      fileCache: fileCache,
      bundle: bundleDataSource(),
      assetPrefix: 'assets',
    );

    final result = await repo.getRoutes('tokaido');

    expect(result, bundledRoutes);
  });
}
