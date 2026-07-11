import 'package:freezed_annotation/freezed_annotation.dart';

part 'spot_dto.freezed.dart';
part 'spot_dto.g.dart';

/// Data transfer object for a spot (宿場・名所) returned by the
/// `/api/v1/maps/{context}/spots` endpoint.
@freezed
abstract class SpotDto with _$SpotDto {
  const factory SpotDto({
    required int id,
    required String title,
    required double lat,
    required double lng,
    required String description,
    required String category,
    String? image,
  }) = _SpotDto;

  factory SpotDto.fromJson(Map<String, dynamic> json) =>
      _$SpotDtoFromJson(json);
}
