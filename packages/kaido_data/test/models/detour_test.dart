import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/models/detour.dart';

void main() {
  group('Detour', () {
    test('fromJson/toJson round trip', () {
      const detour = Detour(
        id: '1',
        name: '寄り道ルート',
        routes: [
          DetourRoutePoint(lat: 35.6835, lng: 139.7742, number: 1),
          DetourRoutePoint(lat: 35.6840, lng: 139.7750, number: 2),
        ],
      );

      final json = detour.toJson();
      final decoded = Detour.fromJson(json);

      expect(decoded, detour);
    });

    test('fromJson defaults routes to empty list', () {
      final json = {'id': 2, 'name': '寄り道2'};

      final detour = Detour.fromJson(json);

      expect(detour.routes, isEmpty);
    });

    test('fromJson handles null route point number', () {
      final json = {
        'id': 3,
        'name': '寄り道3',
        'routes': [
          {'lat': 35.6, 'lng': 139.74, 'number': null},
        ],
      };

      final detour = Detour.fromJson(json);

      expect(detour.routes.single.number, isNull);
    });
  });
}
