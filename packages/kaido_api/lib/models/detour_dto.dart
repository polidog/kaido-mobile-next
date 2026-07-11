import 'package:freezed_annotation/freezed_annotation.dart';

part 'detour_dto.freezed.dart';
part 'detour_dto.g.dart';

/// Data transfer object for a detour route (寄り道) returned by the
/// `/api/v1/maps/{context}/detours` endpoint.
///
/// Fields are provisional until the `kaido-web-next` detour schema is
/// finalized.
@freezed
abstract class DetourDto with _$DetourDto {
  const factory DetourDto({
    required int id,
    required String title,
    required double lat,
    required double lng,
    String? description,
  }) = _DetourDto;

  factory DetourDto.fromJson(Map<String, dynamic> json) =>
      _$DetourDtoFromJson(json);
}
