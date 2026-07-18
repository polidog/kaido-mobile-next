import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/models/route_point.dart';

/// Parses a `#RRGGBB` / `#AARRGGBB` hex string into a [Color].
///
/// Returns null when [hex] is null or malformed so callers can fall back
/// to their default color.
Color? colorFromHex(String? hex) {
  if (hex == null) return null;
  var value = hex.replaceFirst('#', '').trim();
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return null;
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? null : Color(parsed);
}

/// Converts lists of [RoutePoint] into map [Polyline]s, one per `groupId`.
extension RoutePointListToPolylines on List<RoutePoint> {
  /// Groups this list by [RoutePoint.groupId] (defaulting to `''`), sorts
  /// each group by [RoutePoint.order] (defaulting to `0`), and returns one
  /// [Polyline] per group.
  ///
  /// Each group is drawn with its own [RoutePoint.color] when present
  /// (kaido-web-next の色付きポリライン), falling back to [color].
  Set<Polyline> toPolylines({Color color = Colors.blue, int width = 4}) {
    final groups = <String, List<RoutePoint>>{};
    for (final point in this) {
      groups.putIfAbsent(point.groupId ?? '', () => []).add(point);
    }

    return groups.entries.map((entry) {
      final points = List<RoutePoint>.of(entry.value)
        ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
      final groupColor = points
          .map((p) => colorFromHex(p.color))
          .whereType<Color>()
          .firstOrNull;
      return Polyline(
        polylineId: PolylineId('route_${entry.key}'),
        points: points.map((p) => LatLng(p.lat, p.lng)).toList(),
        color: groupColor ?? color,
        width: width,
      );
    }).toSet();
  }
}
