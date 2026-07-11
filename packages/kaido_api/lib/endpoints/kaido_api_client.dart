import 'package:dio/dio.dart';
import 'package:kaido_api/models/detour_dto.dart';
import 'package:kaido_api/models/route_point_dto.dart';
import 'package:kaido_api/models/spot_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'kaido_api_client.g.dart';

/// Type-safe HTTP client for the `kaido-web-next` `/api/v1/maps` API.
@RestApi()
abstract class KaidoApiClient {
  /// Creates a [KaidoApiClient] backed by [dio].
  factory KaidoApiClient(Dio dio, {String baseUrl}) = _KaidoApiClient;

  /// Fetches the spots (宿場・名所) for the given [context] (e.g. `tokaido`).
  @GET('/api/v1/maps/{context}/spots')
  Future<List<SpotDto>> getSpots(@Path('context') String context);

  /// Fetches the route coordinates (本道) for the given [context].
  @GET('/api/v1/maps/{context}/routes')
  Future<List<RoutePointDto>> getRoutes(@Path('context') String context);

  /// Fetches the detour route coordinates (寄り道) for the given [context].
  @GET('/api/v1/maps/{context}/detours')
  Future<List<DetourDto>> getDetours(@Path('context') String context);
}
