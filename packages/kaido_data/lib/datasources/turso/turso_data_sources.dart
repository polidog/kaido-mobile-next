import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/datasources/remote/detours_remote_data_source.dart';
import 'package:kaido_data/datasources/remote/points_remote_data_source.dart';
import 'package:kaido_data/datasources/remote/routes_remote_data_source.dart';
import 'package:kaido_data/datasources/turso/turso_map_database.dart';
import 'package:kaido_data/models/detour.dart';
import 'package:kaido_data/models/point.dart';
import 'package:kaido_data/models/route_point.dart';

/// スポットの `category_id` (1-5) と表示名の対応。
/// kaido-web-next の DB スキーマ定義と各アプリの `markerHues` のキーに一致する。
const Map<int, String> kSpotCategoryNames = {
  1: '宿場',
  2: '一里塚',
  3: '名所',
  4: '浮世絵ポイント',
  5: '見付',
};

/// Turso レプリカを同期してから読み取る共通処理。
///
/// 同期に失敗してもローカルレプリカにデータが残っていればそれを返す
/// （オフライン時は前回同期分で動作する）。
Future<ApiResult<T>> _syncAndRead<T>(
  TursoMapDatabase database,
  String context,
  Future<T> Function() read, {
  required bool Function(T data) isEmpty,
}) async {
  Object? syncError;
  StackTrace? syncStackTrace;
  try {
    await database.sync(context);
  } on Object catch (e, st) {
    syncError = e;
    syncStackTrace = st;
  }
  try {
    final data = await read();
    if (isEmpty(data) && syncError != null) {
      return ApiFailure(syncError, syncStackTrace);
    }
    return ApiSuccess(data);
  } on Object catch (e, st) {
    return ApiFailure(e, st);
  }
}

/// [PointsRemoteDataSource] backed by the Turso embedded replica.
class TursoPointsDataSource implements PointsRemoteDataSource {
  /// Creates a [TursoPointsDataSource].
  TursoPointsDataSource(this._database);

  final TursoMapDatabase _database;

  @override
  Future<ApiResult<List<Point>>> fetch(String context) {
    return _syncAndRead(
      _database,
      context,
      () async {
        final rows = await _database.query(context, '''
          SELECT id, number, title, description, image_file_name,
                 latitude, longitude, category_id
          FROM spots
          ORDER BY number
        ''');
        return rows
            .map(
              (row) => Point(
                id: row['id']?.toString() ?? '',
                title: row['title'] as String? ?? '',
                lat: (row['latitude'] as num?)?.toDouble() ?? 0,
                lng: (row['longitude'] as num?)?.toDouble() ?? 0,
                description: row['description'] as String? ?? '',
                category:
                    kSpotCategoryNames[(row['category_id'] as num?)
                        ?.toInt()] ??
                    '名所',
                image: row['image_file_name'] as String?,
              ),
            )
            .toList();
      },
      isEmpty: (data) => data.isEmpty,
    );
  }
}

/// [RoutesRemoteDataSource] backed by the Turso embedded replica.
class TursoRoutesDataSource implements RoutesRemoteDataSource {
  /// Creates a [TursoRoutesDataSource].
  TursoRoutesDataSource(this._database);

  final TursoMapDatabase _database;

  @override
  Future<ApiResult<List<RoutePoint>>> fetch(String context) {
    return _syncAndRead(
      _database,
      context,
      () async {
        final rows = await _database.query(context, '''
          SELECT rp.id, rp.latitude, rp.longitude, rp.number,
                 rp.route_group_id, rg.color
          FROM route_points rp
          LEFT JOIN route_groups rg ON rg.id = rp.route_group_id
          ORDER BY rp.route_group_id, rp.number
        ''');
        return rows
            .map(
              (row) => RoutePoint(
                id: row['id']?.toString() ?? '',
                lat: (row['latitude'] as num?)?.toDouble() ?? 0,
                lng: (row['longitude'] as num?)?.toDouble() ?? 0,
                order: (row['number'] as num?)?.toInt(),
                groupId: row['route_group_id']?.toString(),
                color: row['color'] as String?,
              ),
            )
            .toList();
      },
      isEmpty: (data) => data.isEmpty,
    );
  }
}

/// [DetoursRemoteDataSource] backed by the Turso embedded replica.
class TursoDetoursDataSource implements DetoursRemoteDataSource {
  /// Creates a [TursoDetoursDataSource].
  TursoDetoursDataSource(this._database);

  final TursoMapDatabase _database;

  @override
  Future<ApiResult<List<Detour>>> fetch(String context) {
    return _syncAndRead(
      _database,
      context,
      () async {
        // 実 DB の detours には color カラムが無い環境がある（スキーマ文書と
        // 実体の差異）ため、SELECT * で取得し color は存在すれば読む。
        final detourRows = await _database.query(context, '''
          SELECT * FROM detours
        ''');
        final pointRows = await _database.query(context, '''
          SELECT detour_id, latitude, longitude, number
          FROM detour_routes
          ORDER BY detour_id, number
        ''');

        final pointsByDetour = <String, List<DetourRoutePoint>>{};
        for (final row in pointRows) {
          final detourId = row['detour_id']?.toString() ?? '';
          pointsByDetour
              .putIfAbsent(detourId, () => [])
              .add(
                DetourRoutePoint(
                  lat: (row['latitude'] as num?)?.toDouble() ?? 0,
                  lng: (row['longitude'] as num?)?.toDouble() ?? 0,
                  number: (row['number'] as num?)?.toInt(),
                ),
              );
        }

        return detourRows.map((row) {
          final id = row['id']?.toString() ?? '';
          return Detour(
            id: id,
            name: row['name'] as String? ?? '',
            color: row['color'] as String?,
            routes: pointsByDetour[id] ?? const [],
          );
        }).toList();
      },
      isEmpty: (data) => data.isEmpty,
    );
  }
}
