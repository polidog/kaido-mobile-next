import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/models/point.dart';

void main() {
  group('Point', () {
    test('fromJson/toJson round trip', () {
      const point = Point(
        id: 1,
        title: '日本橋',
        lat: 35.6835,
        lng: 139.7742,
        description: '五街道の起点',
        category: 'landmark',
        image: 'nihonbashi.png',
      );

      final json = point.toJson();
      final decoded = Point.fromJson(json);

      expect(decoded, point);
    });

    test('fromJson handles null image', () {
      final json = {
        'id': 2,
        'title': '品川宿',
        'lat': 35.6,
        'lng': 139.74,
        'description': '東海道最初の宿場',
        'category': 'juku',
        'image': null,
      };

      final point = Point.fromJson(json);

      expect(point.image, isNull);
      expect(point.title, '品川宿');
    });
  });
}
