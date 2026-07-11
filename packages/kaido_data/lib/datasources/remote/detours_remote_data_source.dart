import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/mappers/dto_mappers.dart';
import 'package:kaido_data/models/detour.dart';

/// Fetches [Detour] data from the remote `kaido-web-next` API.
abstract class DetoursRemoteDataSource {
  /// Fetches detour route coordinates for the given [context].
  Future<ApiResult<List<Detour>>> fetch(String context);
}

/// [DetoursRemoteDataSource] backed by [KaidoApiService].
class ApiDetoursRemoteDataSource implements DetoursRemoteDataSource {
  /// Creates an [ApiDetoursRemoteDataSource].
  ApiDetoursRemoteDataSource(this._apiService);

  final KaidoApiService _apiService;

  @override
  Future<ApiResult<List<Detour>>> fetch(String context) async {
    final result = await _apiService.getDetours(context);
    return switch (result) {
      ApiSuccess(:final data) => ApiSuccess(data.toDetours()),
      ApiFailure(:final error, :final stackTrace) => ApiFailure(
        error,
        stackTrace,
      ),
    };
  }
}
