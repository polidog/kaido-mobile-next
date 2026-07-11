import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/datasources/asset_loader.dart';
import 'package:kaido_data/datasources/file_cache_data_source.dart';
import 'package:kaido_data/datasources/local_bundle_data_source.dart';
import 'package:kaido_data/models/point.dart';
import 'package:kaido_data/repositories/point_repository.dart';

import '../helpers/fake_asset_loader.dart';
import '../helpers/fake_remote_data_sources.dart';

void main() {
  late Directory tempDir;
  late FileCacheDataSource fileCache;

  const bundledPoints = [
    Point(
      id: 99,
      title: 'バンドル',
      lat: 0,
      lng: 0,
      description: 'フォールバック',
      category: 'landmark',
    ),
  ];

  const remotePoints = [
    Point(
      id: 1,
      title: 'API取得',
      lat: 1,
      lng: 2,
      description: 'desc',
      category: 'juku',
    ),
  ];

  const cachedPoints = [
    Point(
      id: 2,
      title: 'キャッシュ',
      lat: 3,
      lng: 4,
      description: 'desc',
      category: 'juku',
    ),
  ];

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('point_repo_test');
    fileCache = FileCacheDataSource(directoryResolver: () async => tempDir);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  LocalBundleDataSource bundleDataSource() {
    final AssetLoader loader = FakeAssetLoader({
      'assets/json/points.json': '''
        [
          {"id": 99, "title": "バンドル", "lat": 0, "lng": 0,
           "description": "フォールバック", "category": "landmark", "image": null}
        ]
      ''',
    });
    return LocalBundleDataSource(loader);
  }

  test('API success returns data and writes to cache', () async {
    final repo = PointRepository(
      remote: FakePointsRemoteDataSource(const ApiSuccess(remotePoints)),
      fileCache: fileCache,
      bundle: bundleDataSource(),
      assetPrefix: 'assets',
    );

    final result = await repo.getPoints('tokaido');

    expect(result, remotePoints);
    final cached = await fileCache.readPoints('tokaido');
    expect(cached, remotePoints);
  });

  test('API failure with existing cache returns cached data', () async {
    await fileCache.cachePoints('tokaido', cachedPoints);

    final repo = PointRepository(
      remote: FakePointsRemoteDataSource(
        ApiFailure(Exception('network error')),
      ),
      fileCache: fileCache,
      bundle: bundleDataSource(),
      assetPrefix: 'assets',
    );

    final result = await repo.getPoints('tokaido');

    expect(result, cachedPoints);
  });

  test(
    'API failure with no cache falls back to bundled JSON',
    () async {
      final repo = PointRepository(
        remote: FakePointsRemoteDataSource(
          ApiFailure(Exception('network error')),
        ),
        fileCache: fileCache,
        bundle: bundleDataSource(),
        assetPrefix: 'assets',
      );

      final result = await repo.getPoints('tokaido');

      expect(result, bundledPoints);
    },
  );
}
