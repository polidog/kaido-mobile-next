import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_summary_dto.freezed.dart';
part 'map_summary_dto.g.dart';

/// Data transfer object for a map (街道) returned by the
/// `/api/v1/maps` endpoint.
@freezed
abstract class MapSummaryDto with _$MapSummaryDto {
  const factory MapSummaryDto({
    required String id,
    required String name,
    required String aliasName,
    bool? hasDatabase,
    String? databaseUrl,
  }) = _MapSummaryDto;

  factory MapSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$MapSummaryDtoFromJson(json);
}

/// Envelope for the `/api/v1/maps` response.
@freezed
abstract class MapsListDto with _$MapsListDto {
  const factory MapsListDto({
    @Default(<MapSummaryDto>[]) List<MapSummaryDto> maps,
  }) = _MapsListDto;

  factory MapsListDto.fromJson(Map<String, dynamic> json) =>
      _$MapsListDtoFromJson(json);
}
