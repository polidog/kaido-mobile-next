import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/datasources/local_bundle_data_source.dart';

import '../helpers/fake_asset_loader.dart';

void main() {
  group('LocalBundleDataSource', () {
    test('loadPoints parses bundled JSON into Points', () async {
      final loader = FakeAssetLoader({
        'assets/json/points.json': '''
        [
          {"id": 1, "title": "日本橋", "lat": 35.6, "lng": 139.7,
           "description": "起点", "category": "landmark", "image": null}
        ]
        ''',
      });
      final source = LocalBundleDataSource(loader);

      final points = await source.loadPoints('assets/json/points.json');

      expect(points, hasLength(1));
      expect(points.first.title, '日本橋');
    });

    test('loadRoutes parses bundled JSON into RoutePoints', () async {
      final loader = FakeAssetLoader({
        'assets/json/routes.json': '[{"id": 1, "lat": 1.0, "lng": 2.0}]',
      });
      final source = LocalBundleDataSource(loader);

      final routes = await source.loadRoutes('assets/json/routes.json');

      expect(routes, hasLength(1));
      expect(routes.first.id, '1');
    });

    test('loadDetours parses bundled JSON into Detours', () async {
      final loader = FakeAssetLoader({
        'assets/json/detours.json':
            '[{"id": 1, "name": "寄り道", "routes": ['
            '{"lat": 1.0, "lng": 2.0, "number": 1}]}]',
      });
      final source = LocalBundleDataSource(loader);

      final detours = await source.loadDetours('assets/json/detours.json');

      expect(detours, hasLength(1));
      expect(detours.first.name, '寄り道');
      expect(detours.first.routes, hasLength(1));
    });
  });
}
