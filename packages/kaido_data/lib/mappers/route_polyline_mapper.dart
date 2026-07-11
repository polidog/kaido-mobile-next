import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/models/route_point.dart';

/// Converts lists of [RoutePoint] into map [Polyline]s, one per `groupId`.
extension RoutePointListToPolylines on List<RoutePoint> {
  /// Groups this list by [RoutePoint.groupId] (defaulting to `0`), sorts
  /// each group by [RoutePoint.order] (defaulting to `0`), and returns one
  /// [Polyline] per group.
  Set<Polyline> toPolylines({Color color = Colors.blue, int width = 4}) {
    final groups = <int, List<RoutePoint>>{};
    for (final point in this) {
      groups.putIfAbsent(point.groupId ?? 0, () => []).add(point);
    }

    return groups.entries.map((entry) {
      final points = List<RoutePoint>.of(entry.value)
        ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
      return Polyline(
        polylineId: PolylineId('route_${entry.key}'),
        points: points.map((p) => LatLng(p.lat, p.lng)).toList(),
        color: color,
        width: width,
      );
    }).toSet();
  }
}
