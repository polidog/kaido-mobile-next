import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/models/detour.dart';

void main() {
  group('Detour', () {
    test('fromJson/toJson round trip', () {
      const detour = Detour(
        id: 1,
        title: '寄り道スポット',
        lat: 35.6835,
        lng: 139.7742,
        description: '立ち寄りポイント',
      );

      final json = detour.toJson();
      final decoded = Detour.fromJson(json);

      expect(decoded, detour);
    });

    test('fromJson handles null description', () {
      final json = {
        'id': 2,
        'title': '寄り道2',
        'lat': 35.6,
        'lng': 139.74,
        'description': null,
      };

      final detour = Detour.fromJson(json);

      expect(detour.description, isNull);
    });
  });
}
