import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/mappers/dto_mappers.dart';
import 'package:kaido_data/models/point.dart';

/// Fetches [Point] data from the remote `kaido-web-next` API.
abstract class PointsRemoteDataSource {
  /// Fetches points for the given [context].
  Future<ApiResult<List<Point>>> fetch(String context);
}

/// [PointsRemoteDataSource] backed by [KaidoApiService].
class ApiPointsRemoteDataSource implements PointsRemoteDataSource {
  /// Creates an [ApiPointsRemoteDataSource].
  ApiPointsRemoteDataSource(this._apiService);

  final KaidoApiService _apiService;

  @override
  Future<ApiResult<List<Point>>> fetch(String context) async {
    final result = await _apiService.getSpots(context);
    return switch (result) {
      ApiSuccess(:final data) => ApiSuccess(data.toPoints()),
      ApiFailure(:final error, :final stackTrace) => ApiFailure(
        error,
        stackTrace,
      ),
    };
  }
}
