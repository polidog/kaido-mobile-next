import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/datasources/file_cache_data_source.dart';
import 'package:kaido_data/models/detour.dart';
import 'package:kaido_data/models/point.dart';
import 'package:kaido_data/models/route_point.dart';

void main() {
  late Directory tempDir;
  late FileCacheDataSource dataSource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('kaido_file_cache_test');
    dataSource = FileCacheDataSource(directoryResolver: () async => tempDir);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FileCacheDataSource points', () {
    test('cachePoints then readPoints round trips', () async {
      const points = [
        Point(
          id: 1,
          title: '日本橋',
          lat: 35.6,
          lng: 139.7,
          description: '起点',
          category: 'landmark',
        ),
      ];

      await dataSource.cachePoints('tokaido', points);
      final result = await dataSource.readPoints('tokaido');

      expect(result, points);
    });

    test('readPoints returns null when no cache file exists', () async {
      final result = await dataSource.readPoints('missing');

      expect(result, isNull);
    });

    test('readPoints returns null for malformed JSON', () async {
      final file = File('${tempDir.path}/broken_points.json');
      await file.writeAsString('not valid json');

      final result = await dataSource.readPoints('broken');

      expect(result, isNull);
    });
  });

  group('FileCacheDataSource routes', () {
    test('cacheRoutes then readRoutes round trips', () async {
      const routes = [RoutePoint(id: 1, lat: 1, lng: 2)];

      await dataSource.cacheRoutes('tokaido', routes);
      final result = await dataSource.readRoutes('tokaido');

      expect(result, routes);
    });

    test('readRoutes returns null when no cache file exists', () async {
      final result = await dataSource.readRoutes('missing');

      expect(result, isNull);
    });
  });

  group('FileCacheDataSource detours', () {
    test('cacheDetours then readDetours round trips', () async {
      const detours = [
        Detour(
          id: 1,
          name: '寄り道',
          routes: [
            DetourRoutePoint(lat: 1, lng: 2, number: 1),
            DetourRoutePoint(lat: 3, lng: 4, number: 2),
          ],
        ),
      ];

      await dataSource.cacheDetours('tokaido', detours);
      final result = await dataSource.readDetours('tokaido');

      expect(result, detours);
    });

    test('readDetours returns null when no cache file exists', () async {
      final result = await dataSource.readDetours('missing');

      expect(result, isNull);
    });
  });
}
