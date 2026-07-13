import 'package:freezed_annotation/freezed_annotation.dart';

part 'detour.freezed.dart';
part 'detour.g.dart';

/// Domain model for a single coordinate of a detour route (寄り道).
@freezed
abstract class DetourRoutePoint with _$DetourRoutePoint {
  /// Creates a [DetourRoutePoint].
  const factory DetourRoutePoint({
    required double lat,
    required double lng,
    int? number,
  }) = _DetourRoutePoint;

  /// Creates a [DetourRoutePoint] from decoded JSON.
  factory DetourRoutePoint.fromJson(Map<String, dynamic> json) =>
      _$DetourRoutePointFromJson(json);
}

/// Domain model for a detour route (寄り道).
@freezed
abstract class Detour with _$Detour {
  /// Creates a [Detour].
  const factory Detour({
    required int id,
    required String name,
    @Default(<DetourRoutePoint>[]) List<DetourRoutePoint> routes,
  }) = _Detour;

  /// Creates a [Detour] from decoded JSON.
  factory Detour.fromJson(Map<String, dynamic> json) =>
      _$DetourFromJson(json);
}
