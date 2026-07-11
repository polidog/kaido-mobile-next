import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/models/map_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_controller_provider.g.dart';

/// Manages the map's camera position, follow/compass modes, and visible
/// region.
@riverpod
class MapController extends _$MapController {
  @override
  MapState build() => const MapState();

  /// Updates the current camera position.
  void updateCameraPosition(CameraPosition position) =>
      state = state.copyWith(cameraPosition: position);

  /// Updates the currently visible map region.
  void updateVisibleRegion(LatLngBounds region) =>
      state = state.copyWith(visibleRegion: region);

  /// Toggles GPS follow mode.
  void toggleFollowUser() =>
      state = state.copyWith(isFollowingUser: !state.isFollowingUser);

  /// Toggles compass mode.
  void toggleCompassMode() =>
      state = state.copyWith(isCompassMode: !state.isCompassMode);
}
