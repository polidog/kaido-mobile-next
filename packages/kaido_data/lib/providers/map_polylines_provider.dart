import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/mappers/detour_polyline_mapper.dart';
import 'package:kaido_data/mappers/route_polyline_mapper.dart';
import 'package:kaido_data/models/detour.dart';
import 'package:kaido_data/models/route_point.dart';
import 'package:kaido_data/providers/detours_provider.dart';
import 'package:kaido_data/providers/routes_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_polylines_provider.g.dart';

/// Polyline color for the main route (本道).
const Color routePolylineColor = Color(0xFFC88080);

/// Polyline width for the main route (本道).
const int routePolylineWidth = 5;

/// Memoized polylines for the main route.
///
/// Route data can exceed 10,000 points, so the grouping/sorting/LatLng
/// conversion is done here once per data change instead of on every map
/// rebuild.
@riverpod
Set<Polyline> routePolylines(Ref ref) {
  final routes = ref.watch(routesProvider).value ?? const <RoutePoint>[];
  return routes.toPolylines(
    color: routePolylineColor,
    width: routePolylineWidth,
  );
}

/// Memoized polylines for detour routes (寄り道), using the mapper's
/// default styling. See [routePolylines].
@riverpod
Set<Polyline> detourPolylines(Ref ref) {
  final detours = ref.watch(detoursProvider).value ?? const <Detour>[];
  return detours.toPolylines();
}
