import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/mappers/route_polyline_mapper.dart';
import 'package:kaido_data/models/route_point.dart';

void main() {
  group('RoutePointListToPolylines', () {
    test('groups route points by groupId into separate polylines', () {
      const routePoints = [
        RoutePoint(id: '1', lat: 1, lng: 1, groupId: '1'),
        RoutePoint(id: '2', lat: 2, lng: 2, groupId: '1'),
        RoutePoint(id: '3', lat: 3, lng: 3, groupId: '2'),
      ];

      final polylines = routePoints.toPolylines();

      expect(polylines, hasLength(2));
    });

    test('groups points without a groupId into a single default group', () {
      const routePoints = [
        RoutePoint(id: '1', lat: 1, lng: 1),
        RoutePoint(id: '2', lat: 2, lng: 2),
      ];

      final polylines = routePoints.toPolylines();

      expect(polylines, hasLength(1));
      expect(polylines.single.points, hasLength(2));
    });

    test('sorts points within a group by order', () {
      const routePoints = [
        RoutePoint(id: '1', lat: 1, lng: 1, groupId: '1', order: 2),
        RoutePoint(id: '2', lat: 2, lng: 2, groupId: '1', order: 0),
        RoutePoint(id: '3', lat: 3, lng: 3, groupId: '1', order: 1),
      ];

      final polylines = routePoints.toPolylines();
      final points = polylines.single.points;

      expect(points, [
        const LatLng(2, 2),
        const LatLng(3, 3),
        const LatLng(1, 1),
      ]);
    });

    test('treats a null order as order 0', () {
      const routePoints = [
        RoutePoint(id: '1', lat: 1, lng: 1, groupId: '1', order: 1),
        RoutePoint(id: '2', lat: 2, lng: 2, groupId: '1'),
      ];

      final polylines = routePoints.toPolylines();
      final points = polylines.single.points;

      expect(points, [const LatLng(2, 2), const LatLng(1, 1)]);
    });

    test('applies the given color and width', () {
      const routePoints = [RoutePoint(id: '1', lat: 1, lng: 1)];

      final polylines = routePoints.toPolylines(
        color: Colors.red,
        width: 8,
      );

      expect(polylines.single.color, Colors.red);
      expect(polylines.single.width, 8);
    });

    test('returns an empty set for an empty list', () {
      expect(<RoutePoint>[].toPolylines(), isEmpty);
    });
  });
}
