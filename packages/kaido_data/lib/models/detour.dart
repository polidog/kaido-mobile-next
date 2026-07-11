import 'package:freezed_annotation/freezed_annotation.dart';

part 'detour.freezed.dart';
part 'detour.g.dart';

/// Domain model for a detour route (寄り道).
@freezed
abstract class Detour with _$Detour {
  /// Creates a [Detour].
  const factory Detour({
    required int id,
    required String title,
    required double lat,
    required double lng,
    String? description,
  }) = _Detour;

  /// Creates a [Detour] from decoded JSON.
  factory Detour.fromJson(Map<String, dynamic> json) =>
      _$DetourFromJson(json);
}
