import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_point_dto.freezed.dart';
part 'route_point_dto.g.dart';

/// Data transfer object for a route coordinate (本道) returned by the
/// `/api/v1/maps/{context}/routes` endpoint.
///
/// Fields are provisional until the `kaido-web-next` route schema is
/// finalized.
@freezed
abstract class RoutePointDto with _$RoutePointDto {
  const factory RoutePointDto({
    required int id,
    required double lat,
    required double lng,
    int? order,
    int? groupId,
  }) = _RoutePointDto;

  factory RoutePointDto.fromJson(Map<String, dynamic> json) =>
      _$RoutePointDtoFromJson(json);
}
