import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/mappers/dto_mappers.dart';
import 'package:kaido_data/models/route_point.dart';

/// Fetches [RoutePoint] data from the remote `kaido-web-next` API.
abstract class RoutesRemoteDataSource {
  /// Fetches route coordinates for the given [context].
  Future<ApiResult<List<RoutePoint>>> fetch(String context);
}

/// [RoutesRemoteDataSource] backed by [KaidoApiService].
class ApiRoutesRemoteDataSource implements RoutesRemoteDataSource {
  /// Creates an [ApiRoutesRemoteDataSource].
  ApiRoutesRemoteDataSource(this._apiService);

  final KaidoApiService _apiService;

  @override
  Future<ApiResult<List<RoutePoint>>> fetch(String context) async {
    final result = await _apiService.getRoutes(context);
    return switch (result) {
      ApiSuccess(:final data) => ApiSuccess(data.toRoutePoints()),
      ApiFailure(:final error, :final stackTrace) => ApiFailure(
        error,
        stackTrace,
      ),
    };
  }
}
