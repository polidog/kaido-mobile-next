import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/models/route_point.dart';

void main() {
  group('RoutePoint', () {
    test('fromJson/toJson round trip', () {
      const routePoint = RoutePoint(
        id: 1,
        lat: 35.6835,
        lng: 139.7742,
        order: 1,
        groupId: 10,
      );

      final json = routePoint.toJson();
      final decoded = RoutePoint.fromJson(json);

      expect(decoded, routePoint);
    });

    test('fromJson handles null optional fields', () {
      final json = {'id': 2, 'lat': 35.6, 'lng': 139.74};

      final routePoint = RoutePoint.fromJson(json);

      expect(routePoint.order, isNull);
      expect(routePoint.groupId, isNull);
    });
  });
}
