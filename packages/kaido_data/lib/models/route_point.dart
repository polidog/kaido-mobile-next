import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kaido_data/models/json_converters.dart';

part 'route_point.freezed.dart';
part 'route_point.g.dart';

/// Domain model for a route coordinate (本道).
@freezed
abstract class RoutePoint with _$RoutePoint {
  /// Creates a [RoutePoint].
  const factory RoutePoint({
    @JsonKey(fromJson: jsonIdToString) required String id,
    required double lat,
    required double lng,
    int? order,
    @JsonKey(fromJson: jsonIdToStringOrNull) String? groupId,
    String? color,
  }) = _RoutePoint;

  /// Creates a [RoutePoint] from decoded JSON.
  factory RoutePoint.fromJson(Map<String, dynamic> json) =>
      _$RoutePointFromJson(json);
}
