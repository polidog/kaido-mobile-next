import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kaido_data/models/json_converters.dart';

part 'point.freezed.dart';
part 'point.g.dart';

/// Domain model for a point of interest (宿場・名所).
@freezed
abstract class Point with _$Point {
  /// Creates a [Point].
  const factory Point({
    @JsonKey(fromJson: jsonIdToString) required String id,
    required String title,
    required double lat,
    required double lng,
    required String description,
    required String category,
    String? image,
  }) = _Point;

  /// Creates a [Point] from decoded JSON.
  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);
}
