import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/pages/map_page.dart';

Point _pointAt(int id, double lat, double lng) => Point(
  id: id,
  title: 'point $id',
  lat: lat,
  lng: lng,
  description: '',
  category: 'category',
);

void main() {
  group('filterVisiblePoints', () {
    final bounds = LatLngBounds(
      southwest: const LatLng(35, 139),
      northeast: const LatLng(36, 140),
    );

    test('returns all points when bounds is null', () {
      final points = [_pointAt(1, 0, 0), _pointAt(2, 90, 180)];

      expect(filterVisiblePoints(points, null), points);
    });

    test('keeps points inside the bounds', () {
      final inside = _pointAt(1, 35.5, 139.5);

      expect(filterVisiblePoints([inside], bounds), [inside]);
    });

    test('drops points outside the bounds', () {
      final outside = _pointAt(1, 10, 10);

      expect(filterVisiblePoints([outside], bounds), isEmpty);
    });

    test('keeps points exactly on the bounds edges', () {
      final southwestCorner = _pointAt(1, 35, 139);
      final northeastCorner = _pointAt(2, 36, 140);

      expect(
        filterVisiblePoints([southwestCorner, northeastCorner], bounds),
        [southwestCorner, northeastCorner],
      );
    });

    test('filters a mixed list to only the points inside bounds', () {
      final inside = _pointAt(1, 35.5, 139.5);
      final outside = _pointAt(2, 10, 10);

      expect(filterVisiblePoints([inside, outside], bounds), [inside]);
    });
  });
}
