import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_point.freezed.dart';
part 'route_point.g.dart';

/// Domain model for a route coordinate (本道).
@freezed
abstract class RoutePoint with _$RoutePoint {
  /// Creates a [RoutePoint].
  const factory RoutePoint({
    required int id,
    required double lat,
    required double lng,
    int? order,
    int? groupId,
  }) = _RoutePoint;

  /// Creates a [RoutePoint] from decoded JSON.
  factory RoutePoint.fromJson(Map<String, dynamic> json) =>
      _$RoutePointFromJson(json);
}
