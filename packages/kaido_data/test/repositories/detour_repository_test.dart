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

  const bundledDetours = [Detour(id: 99, title: 'バンドル', lat: 0, lng: 0)];
  const remoteDetours = [Detour(id: 1, title: 'API取得', lat: 1, lng: 2)];
  const cachedDetours = [Detour(id: 2, title: 'キャッシュ', lat: 3, lng: 4)];

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
          '[{"id": 99, "title": "バンドル", "lat": 0.0, "lng": 0.0}]',
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
