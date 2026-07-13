import 'package:freezed_annotation/freezed_annotation.dart';

part 'detour_dto.freezed.dart';
part 'detour_dto.g.dart';

/// Data transfer object for a single coordinate of a detour route (寄り道)
/// returned by the `/api/v1/maps/{context}/detours` endpoint.
///
/// Fields are provisional until the `kaido-web-next` detour schema is
/// finalized.
@freezed
abstract class DetourRoutePointDto with _$DetourRoutePointDto {
  const factory DetourRoutePointDto({
    required double lat,
    required double lng,
    int? number,
  }) = _DetourRoutePointDto;

  factory DetourRoutePointDto.fromJson(Map<String, dynamic> json) =>
      _$DetourRoutePointDtoFromJson(json);
}

/// Data transfer object for a detour route (寄り道) returned by the
/// `/api/v1/maps/{context}/detours` endpoint.
///
/// Fields are provisional until the `kaido-web-next` detour schema is
/// finalized.
@freezed
abstract class DetourDto with _$DetourDto {
  const factory DetourDto({
    required int id,
    required String name,
    @Default(<DetourRoutePointDto>[]) List<DetourRoutePointDto> routes,
  }) = _DetourDto;

  factory DetourDto.fromJson(Map<String, dynamic> json) =>
      _$DetourDtoFromJson(json);
}
