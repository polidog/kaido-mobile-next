import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/models/detour.dart';
import 'package:kaido_data/models/point.dart';
import 'package:kaido_data/models/route_point.dart';

/// Converts [SpotDto] instances into domain [Point] models.
extension SpotDtoMapper on SpotDto {
  /// Converts this DTO into a domain [Point].
  Point toPoint() => Point(
    id: id,
    title: title,
    lat: lat,
    lng: lng,
    description: description,
    category: category,
    image: image,
  );
}

/// Converts lists of [SpotDto] into lists of domain [Point] models.
extension SpotDtoListMapper on List<SpotDto> {
  /// Converts this list of DTOs into a list of domain [Point]s.
  List<Point> toPoints() => map((dto) => dto.toPoint()).toList();
}

/// Converts [RoutePointDto] instances into domain [RoutePoint] models.
extension RoutePointDtoMapper on RoutePointDto {
  /// Converts this DTO into a domain [RoutePoint].
  RoutePoint toRoutePoint() =>
      RoutePoint(id: id, lat: lat, lng: lng, order: order, groupId: groupId);
}

/// Converts lists of [RoutePointDto] into lists of domain [RoutePoint]
/// models.
extension RoutePointDtoListMapper on List<RoutePointDto> {
  /// Converts this list of DTOs into a list of domain [RoutePoint]s.
  List<RoutePoint> toRoutePoints() =>
      map((dto) => dto.toRoutePoint()).toList();
}

/// Converts [DetourDto] instances into domain [Detour] models.
extension DetourDtoMapper on DetourDto {
  /// Converts this DTO into a domain [Detour].
  Detour toDetour() => Detour(
    id: id,
    title: title,
    lat: lat,
    lng: lng,
    description: description,
  );
}

/// Converts lists of [DetourDto] into lists of domain [Detour] models.
extension DetourDtoListMapper on List<DetourDto> {
  /// Converts this list of DTOs into a list of domain [Detour]s.
  List<Detour> toDetours() => map((dto) => dto.toDetour()).toList();
}
