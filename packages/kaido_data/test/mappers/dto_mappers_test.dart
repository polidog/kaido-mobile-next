import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/mappers/dto_mappers.dart';

void main() {
  group('SpotDtoMapper', () {
    test('toPoint converts fields 1:1', () {
      const dto = SpotDto(
        id: 1,
        title: '日本橋',
        lat: 35.6835,
        lng: 139.7742,
        description: '五街道の起点',
        category: 'landmark',
        image: 'nihonbashi.png',
      );

      final point = dto.toPoint();

      expect(point.id, dto.id.toString());
      expect(point.title, dto.title);
      expect(point.lat, dto.lat);
      expect(point.lng, dto.lng);
      expect(point.description, dto.description);
      expect(point.category, dto.category);
      expect(point.image, dto.image);
    });

    test('toPoints converts a list', () {
      const dtos = [
        SpotDto(
          id: 1,
          title: 'A',
          lat: 1,
          lng: 2,
          description: 'a',
          category: 'juku',
        ),
        SpotDto(
          id: 2,
          title: 'B',
          lat: 3,
          lng: 4,
          description: 'b',
          category: 'juku',
        ),
      ];

      final points = dtos.toPoints();

      expect(points, hasLength(2));
      expect(points[0].id, '1');
      expect(points[1].id, '2');
    });
  });

  group('RoutePointDtoMapper', () {
    test('toRoutePoint converts fields 1:1', () {
      const dto = RoutePointDto(id: 1, lat: 35.6, lng: 139.7, order: 1);

      final routePoint = dto.toRoutePoint();

      expect(routePoint.id, dto.id.toString());
      expect(routePoint.lat, dto.lat);
      expect(routePoint.lng, dto.lng);
      expect(routePoint.order, dto.order);
      expect(routePoint.groupId, dto.groupId?.toString());
    });

    test('toRoutePoints converts a list', () {
      const dtos = [
        RoutePointDto(id: 1, lat: 1, lng: 2),
        RoutePointDto(id: 2, lat: 3, lng: 4),
      ];

      expect(dtos.toRoutePoints(), hasLength(2));
    });
  });

  group('DetourDtoMapper', () {
    test('toDetour converts fields 1:1', () {
      const dto = DetourDto(
        id: 1,
        name: '寄り道',
        routes: [
          DetourRoutePointDto(lat: 35.6, lng: 139.7, number: 1),
          DetourRoutePointDto(lat: 35.7, lng: 139.8, number: 2),
        ],
      );

      final detour = dto.toDetour();

      expect(detour.id, dto.id.toString());
      expect(detour.name, dto.name);
      expect(detour.routes, hasLength(2));
      expect(detour.routes[0].lat, dto.routes[0].lat);
      expect(detour.routes[0].lng, dto.routes[0].lng);
      expect(detour.routes[0].number, dto.routes[0].number);
    });

    test('toDetours converts a list', () {
      const dtos = [
        DetourDto(id: 1, name: 'A'),
        DetourDto(id: 2, name: 'B'),
      ];

      expect(dtos.toDetours(), hasLength(2));
    });
  });
}
