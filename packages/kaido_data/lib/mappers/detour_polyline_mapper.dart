import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/mappers/route_polyline_mapper.dart';
import 'package:kaido_data/models/detour.dart';

/// Converts lists of [Detour] into map [Polyline]s, one per detour.
extension DetourListToPolylines on List<Detour> {
  /// Sorts each detour's route points by [DetourRoutePoint.number]
  /// (defaulting to `0`) and returns one [Polyline] per detour.
  ///
  /// Each detour is drawn with its own [Detour.color] when present,
  /// falling back to [color]. Detours with fewer than two route points
  /// are skipped since they cannot form a line.
  Set<Polyline> toPolylines({Color color = Colors.green, int width = 3}) {
    return where((detour) => detour.routes.length >= 2).map((detour) {
      final points = List<DetourRoutePoint>.of(detour.routes)
        ..sort((a, b) => (a.number ?? 0).compareTo(b.number ?? 0));
      return Polyline(
        polylineId: PolylineId('detour_${detour.id}'),
        points: points.map((p) => LatLng(p.lat, p.lng)).toList(),
        color: colorFromHex(detour.color) ?? color,
        width: width,
      );
    }).toSet();
  }
}
