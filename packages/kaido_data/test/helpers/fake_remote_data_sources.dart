import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/datasources/remote/detours_remote_data_source.dart';
import 'package:kaido_data/datasources/remote/points_remote_data_source.dart';
import 'package:kaido_data/datasources/remote/routes_remote_data_source.dart';
import 'package:kaido_data/models/detour.dart';
import 'package:kaido_data/models/point.dart';
import 'package:kaido_data/models/route_point.dart';

/// Fake [PointsRemoteDataSource] returning a preconfigured [ApiResult].
class FakePointsRemoteDataSource implements PointsRemoteDataSource {
  FakePointsRemoteDataSource(this.result);

  final ApiResult<List<Point>> result;

  @override
  Future<ApiResult<List<Point>>> fetch(String context) async => result;
}

/// Fake [RoutesRemoteDataSource] returning a preconfigured [ApiResult].
class FakeRoutesRemoteDataSource implements RoutesRemoteDataSource {
  FakeRoutesRemoteDataSource(this.result);

  final ApiResult<List<RoutePoint>> result;

  @override
  Future<ApiResult<List<RoutePoint>>> fetch(String context) async => result;
}

/// Fake [DetoursRemoteDataSource] returning a preconfigured [ApiResult].
class FakeDetoursRemoteDataSource implements DetoursRemoteDataSource {
  FakeDetoursRemoteDataSource(this.result);

  final ApiResult<List<Detour>> result;

  @override
  Future<ApiResult<List<Detour>>> fetch(String context) async => result;
}
