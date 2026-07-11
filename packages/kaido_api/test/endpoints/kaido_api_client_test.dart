import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_api/client.dart';
import 'package:kaido_api/endpoints/kaido_api_client.dart';
import 'package:kaido_api/models/detour_dto.dart';
import 'package:kaido_api/models/route_point_dto.dart';
import 'package:kaido_api/models/spot_dto.dart';
import 'package:kaido_api/result.dart';

import '../helpers/fake_http_client_adapter.dart';

void main() {
  late Dio dio;
  late KaidoApiClient client;
  late KaidoApiService service;

  group('KaidoApiClient + KaidoApiService', () {
    test('getSpots returns ApiSuccess on 200', () async {
      dio = Dio(BaseOptions(baseUrl: 'https://example.com'))
        ..httpClientAdapter = FakeHttpClientAdapter(
          onRequest: (_) => FakeHttpClientAdapter.jsonResponse([
            {
              'id': 1,
              'title': '品川宿',
              'lat': 35.6,
              'lng': 139.7,
              'description': '東海道の宿場',
              'category': 'shukuba',
            },
          ]),
        );
      client = KaidoApiClient(dio);
      service = KaidoApiService(client);

      final result = await service.getSpots('tokaido');
      expect(result, isA<ApiSuccess<List<SpotDto>>>());
      final spots = (result as ApiSuccess<List<SpotDto>>).data;
      expect(spots, hasLength(1));
      expect(spots.first.title, '品川宿');
      expect(spots.first.category, 'shukuba');
    });

    test('getRoutes returns ApiSuccess on 200', () async {
      dio = Dio(BaseOptions(baseUrl: 'https://example.com'))
        ..httpClientAdapter = FakeHttpClientAdapter(
          onRequest: (_) => FakeHttpClientAdapter.jsonResponse([
            {'id': 1, 'lat': 35.0, 'lng': 139.0, 'order': 1},
          ]),
        );
      client = KaidoApiClient(dio);
      service = KaidoApiService(client);

      final result = await service.getRoutes('tokaido');
      expect(result, isA<ApiSuccess<List<RoutePointDto>>>());
      final routes = (result as ApiSuccess<List<RoutePointDto>>).data;
      expect(routes, hasLength(1));
      expect(routes.first.order, 1);
    });

    test('getDetours returns ApiSuccess on 200', () async {
      dio = Dio(BaseOptions(baseUrl: 'https://example.com'))
        ..httpClientAdapter = FakeHttpClientAdapter(
          onRequest: (_) => FakeHttpClientAdapter.jsonResponse([
            {
              'id': 1,
              'title': '寄り道スポット',
              'lat': 35.1,
              'lng': 139.1,
            },
          ]),
        );
      client = KaidoApiClient(dio);
      service = KaidoApiService(client);

      final result = await service.getDetours('tokaido');
      expect(result, isA<ApiSuccess<List<DetourDto>>>());
      final detours = (result as ApiSuccess<List<DetourDto>>).data;
      expect(detours, hasLength(1));
      expect(detours.first.title, '寄り道スポット');
    });

    test('returns ApiFailure on server error', () async {
      dio = Dio(BaseOptions(baseUrl: 'https://example.com'))
        ..httpClientAdapter = FakeHttpClientAdapter(
          onRequest: (_) => FakeHttpClientAdapter.jsonResponse(
            {'error': 'internal'},
            statusCode: 500,
          ),
        );
      client = KaidoApiClient(dio);
      service = KaidoApiService(client);

      final result = await service.getSpots('tokaido');
      expect(result, isA<ApiFailure<List<SpotDto>>>());
      final failure = result as ApiFailure<List<SpotDto>>;
      expect(failure.error, isA<DioException>());
    });
  });
}
