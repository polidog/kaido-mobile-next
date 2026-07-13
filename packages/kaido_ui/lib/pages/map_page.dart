import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/widgets/bottom_bar.dart';
import 'package:kaido_ui/widgets/map_point_card.dart';

/// Fallback camera target when no persisted or initial location is
/// available (Tokyo Station).
const LatLng _fallbackTarget = LatLng(35.6812, 139.7671);

/// Fallback camera zoom level, paired with [_fallbackTarget].
const double _fallbackZoom = 14;

/// Polyline color for the main route (本道).
const Color _routeColor = Color(0xFFC88080);

/// Polyline width for the main route (本道).
const int _routeWidth = 5;

/// Polyline color for detour routes (寄り道).
const Color _detourColor = Colors.green;

/// Polyline width for detour routes (寄り道).
const int _detourWidth = 3;

bool _isWithinBounds(LatLngBounds bounds, LatLng point) {
  return point.latitude >= bounds.southwest.latitude &&
      point.latitude <= bounds.northeast.latitude &&
      point.longitude >= bounds.southwest.longitude &&
      point.longitude <= bounds.northeast.longitude;
}

/// Filters [points] down to those within [bounds].
///
/// If [bounds] is `null` (e.g. before the map has reported its first
/// visible region), all [points] are returned.
List<Point> filterVisiblePoints(List<Point> points, LatLngBounds? bounds) {
  if (bounds == null) return points;
  return points
      .where((point) => _isWithinBounds(bounds, LatLng(point.lat, point.lng)))
      .toList();
}

/// Map screen (`/`).
class MapPage extends ConsumerStatefulWidget {
  /// Creates a [MapPage].
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _controller;
  CameraPosition? _lastCameraPosition;
  Point? _selectedPoint;

  void _selectPoint(Point point) {
    setState(() => _selectedPoint = point);
    // カードに隠れないよう、タップしたマーカーを画面中央へ寄せる。
    unawaited(
      _controller?.animateCamera(
        CameraUpdate.newLatLng(LatLng(point.lat, point.lng)),
      ),
    );
  }

  void _clearSelectedPoint() {
    if (_selectedPoint == null) return;
    setState(() => _selectedPoint = null);
  }

  Future<void> _handleCameraIdle() async {
    final controller = _controller;
    if (controller == null) return;

    final region = await controller.getVisibleRegion();
    ref.read(mapControllerProvider.notifier).updateVisibleRegion(region);

    final position = _lastCameraPosition;
    if (position != null) {
      final config = ref.read(kaidoConfigProvider);
      final storage = ref.read(cameraPositionStorageProvider);
      await storage.write(config.apiContext, position);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(kaidoConfigProvider);
    final pointsAsync = ref.watch(pointsProvider);
    final routesAsync = ref.watch(routesProvider);
    final detoursAsync = ref.watch(detoursProvider);
    final mapState = ref.watch(mapControllerProvider);
    final initialCameraAsync = ref.watch(initialCameraPositionProvider);
    final markersVisible = ref.watch(markerVisibilityProvider);

    ref
      ..listen(currentPositionProvider, (previous, next) {
        final position = next.value;
        final controller = _controller;
        if (position == null || controller == null) return;
        if (!ref.read(mapControllerProvider).isFollowingUser) return;
        unawaited(
          controller.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude),
            ),
          ),
        );
      })
      ..listen(compassHeadingProvider, (previous, next) {
        final heading = next.value;
        final controller = _controller;
        if (heading == null || controller == null) return;
        if (!ref.read(mapControllerProvider).isCompassMode) return;
        final current = _lastCameraPosition;
        unawaited(
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: current?.target ?? _fallbackTarget,
                zoom: current?.zoom ?? _fallbackZoom,
                bearing: heading,
                tilt: current?.tilt ?? 0,
              ),
            ),
          ),
        );
      });

    return Scaffold(
      body: initialCameraAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildMap(
          config: config,
          pointsAsync: pointsAsync,
          routesAsync: routesAsync,
          detoursAsync: detoursAsync,
          mapState: mapState,
          markersVisible: markersVisible,
          initialCameraPosition: const CameraPosition(
            target: _fallbackTarget,
            zoom: _fallbackZoom,
          ),
        ),
        data: (cameraPosition) => _buildMap(
          config: config,
          pointsAsync: pointsAsync,
          routesAsync: routesAsync,
          detoursAsync: detoursAsync,
          mapState: mapState,
          markersVisible: markersVisible,
          initialCameraPosition:
              cameraPosition ??
              const CameraPosition(
                target: _fallbackTarget,
                zoom: _fallbackZoom,
              ),
        ),
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }

  Widget _buildMap({
    required KaidoConfig config,
    required AsyncValue<List<Point>> pointsAsync,
    required AsyncValue<List<RoutePoint>> routesAsync,
    required AsyncValue<List<Detour>> detoursAsync,
    required MapState mapState,
    required bool markersVisible,
    required CameraPosition initialCameraPosition,
  }) {
    final points = pointsAsync.value ?? const <Point>[];
    final routes = routesAsync.value ?? const <RoutePoint>[];
    final detours = detoursAsync.value ?? const <Detour>[];
    final isLoading = pointsAsync.isLoading ||
        routesAsync.isLoading ||
        detoursAsync.isLoading;

    final markers = markersVisible
        ? filterVisiblePoints(points, mapState.visibleRegion)
              .map(
                (point) => Marker(
                  markerId: MarkerId('point_${point.id}'),
                  position: LatLng(point.lat, point.lng),
                  // カテゴリごとの色相付き標準マーカー（旧アプリと同じ方式）
                  icon: switch (config.markerHues[point.category]) {
                    final hue? => BitmapDescriptor.defaultMarkerWithHue(hue),
                    null => BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueViolet,
                    ),
                  },
                  onTap: () => _selectPoint(point),
                ),
              )
              .toSet()
        : const <Marker>{};

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialCameraPosition,
          markers: markers,
          polylines: {
            ...routes.toPolylines(color: _routeColor, width: _routeWidth),
            ...detours.toPolylines(color: _detourColor, width: _detourWidth),
          },
          onMapCreated: (controller) {
            _controller = controller;
            _lastCameraPosition ??= initialCameraPosition;
          },
          onCameraMove: (position) => _lastCameraPosition = position,
          onCameraIdle: _handleCameraIdle,
          onTap: (_) => _clearSelectedPoint(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        if (isLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: switch (_selectedPoint) {
              null => const SizedBox.shrink(),
              final point => MapPointCard(
                key: ValueKey(point.id),
                point: point,
                assetPrefix: config.assetPrefix,
                accentHue: config.markerHues[point.category],
                onTap: () => context.push('/info/${point.id}'),
                onClose: _clearSelectedPoint,
              ),
            },
          ),
        ),
      ],
    );
  }
}
