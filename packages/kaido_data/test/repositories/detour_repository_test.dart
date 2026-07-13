import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/datasources/asset_loader.dart';
import 'package:kaido_data/datasources/file_cache_data_source.dart';
import 'package:kaido_data/datasources/local_bundle_data_source.dart';
import 'package:kaido_data/models/detour.dart';
import 'package:kaido_data/repositories/detour_repository.dart';

import '../helpers/fake_asset_loader.dart';
import '../helpers/fake_remote_data_sources.dart';

void main() {
  late Directory tempDir;
  late FileCacheDataSource fileCache;

  const bundledDetours = [
    Detour(
      id: 99,
      name: 'バンドル',
      routes: [
        DetourRoutePoint(lat: 0, lng: 0, number: 1),
        DetourRoutePoint(lat: 0.1, lng: 0.1, number: 2),
      ],
    ),
  ];
  const remoteDetours = [
    Detour(
      id: 1,
      name: 'API取得',
      routes: [
        DetourRoutePoint(lat: 1, lng: 2, number: 1),
        DetourRoutePoint(lat: 1.1, lng: 2.1, number: 2),
      ],
    ),
  ];
  const cachedDetours = [
    Detour(
      id: 2,
      name: 'キャッシュ',
      routes: [
        DetourRoutePoint(lat: 3, lng: 4, number: 1),
        DetourRoutePoint(lat: 3.1, lng: 4.1, number: 2),
      ],
    ),
  ];

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('detour_repo_test');
    fileCache = FileCacheDataSource(directoryResolver: () async => tempDir);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  LocalBundleDataSource bundleDataSource() {
    final AssetLoader loader = FakeAssetLoader({
      'assets/json/detours.json':
          '[{"id": 99, "name": "バンドル", "routes": ['
          '{"lat": 0.0, "lng": 0.0, "number": 1}, '
          '{"lat": 0.1, "lng": 0.1, "number": 2}]}]',
    });
    return LocalBundleDataSource(loader);
  }

  test('API success returns data and writes to cache', () async {
    final repo = DetourRepository(
      remote: FakeDetoursRemoteDataSource(const ApiSuccess(remoteDetours)),
      fileCache: fileCache,
      bundle: bundleDataSource(),
      assetPrefix: 'assets',
    );

    final result = await repo.getDetours('tokaido');

    expect(result, remoteDetours);
    final cached = await fileCache.readDetours('tokaido');
    expect(cached, remoteDetours);
  });

  test('API failure with existing cache returns cached data', () async {
    await fileCache.cacheDetours('tokaido', cachedDetours);

    final repo = DetourRepository(
      remote: FakeDetoursRemoteDataSource(
        ApiFailure(Exception('network error')),
      ),
      fileCache: fileCache,
      bundle: bundleDataSource(),
      assetPrefix: 'assets',
    );

    final result = await repo.getDetours('tokaido');

    expect(result, cachedDetours);
  });

  test('API failure with no cache falls back to bundled JSON', () async {
    final repo = DetourRepository(
      remote: FakeDetoursRemoteDataSource(
        ApiFailure(Exception('network error')),
      ),
      fileCache: fileCache,
      bundle: bundleDataSource(),
      assetPrefix: 'assets',
    );

    final result = await repo.getDetours('tokaido');

    expect(result, bundledDetours);
  });
}
