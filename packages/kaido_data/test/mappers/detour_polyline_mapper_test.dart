import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/mappers/detour_polyline_mapper.dart';
import 'package:kaido_data/models/detour.dart';

void main() {
  group('DetourListToPolylines', () {
    test('creates one polyline per detour', () {
      const detours = [
        Detour(
          id: 1,
          name: 'A',
          routes: [
            DetourRoutePoint(lat: 1, lng: 1, number: 1),
            DetourRoutePoint(lat: 2, lng: 2, number: 2),
          ],
        ),
        Detour(
          id: 2,
          name: 'B',
          routes: [
            DetourRoutePoint(lat: 3, lng: 3, number: 1),
            DetourRoutePoint(lat: 4, lng: 4, number: 2),
          ],
        ),
      ];

      final polylines = detours.toPolylines();

      expect(polylines, hasLength(2));
      expect(
        polylines.map((p) => p.polylineId.value),
        containsAll(['detour_1', 'detour_2']),
      );
    });

    test('sorts route points by number', () {
      const detours = [
        Detour(
          id: 1,
          name: 'A',
          routes: [
            DetourRoutePoint(lat: 3, lng: 3, number: 2),
            DetourRoutePoint(lat: 1, lng: 1, number: 0),
            DetourRoutePoint(lat: 2, lng: 2, number: 1),
          ],
        ),
      ];

      final points = detours.toPolylines().single.points;

      expect(points, [
        const LatLng(1, 1),
        const LatLng(2, 2),
        const LatLng(3, 3),
      ]);
    });

    test('treats a null number as 0', () {
      const detours = [
        Detour(
          id: 1,
          name: 'A',
          routes: [
            DetourRoutePoint(lat: 1, lng: 1, number: 1),
            DetourRoutePoint(lat: 2, lng: 2),
          ],
        ),
      ];

      final points = detours.toPolylines().single.points;

      expect(points, [const LatLng(2, 2), const LatLng(1, 1)]);
    });

    test('skips detours with fewer than two route points', () {
      const detours = [
        Detour(id: 1, name: 'empty'),
        Detour(
          id: 2,
          name: 'single',
          routes: [DetourRoutePoint(lat: 1, lng: 1, number: 1)],
        ),
      ];

      expect(detours.toPolylines(), isEmpty);
    });

    test('applies the given color and width', () {
      const detours = [
        Detour(
          id: 1,
          name: 'A',
          routes: [
            DetourRoutePoint(lat: 1, lng: 1, number: 1),
            DetourRoutePoint(lat: 2, lng: 2, number: 2),
          ],
        ),
      ];

      final polyline = detours.toPolylines(color: Colors.red, width: 8).single;

      expect(polyline.color, Colors.red);
      expect(polyline.width, 8);
    });

    test('defaults to green with width 3', () {
      const detours = [
        Detour(
          id: 1,
          name: 'A',
          routes: [
            DetourRoutePoint(lat: 1, lng: 1, number: 1),
            DetourRoutePoint(lat: 2, lng: 2, number: 2),
          ],
        ),
      ];

      final polyline = detours.toPolylines().single;

      expect(polyline.color, Colors.green);
      expect(polyline.width, 3);
    });

    test('returns an empty set for an empty list', () {
      expect(<Detour>[].toPolylines(), isEmpty);
    });
  });
}
