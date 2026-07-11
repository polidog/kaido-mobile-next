import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_state.freezed.dart';

/// State for the map controller: camera position, follow/compass modes,
/// and the currently visible region.
@freezed
abstract class MapState with _$MapState {
  /// Creates a [MapState].
  const factory MapState({
    CameraPosition? cameraPosition,
    @Default(false) bool isFollowingUser,
    @Default(false) bool isCompassMode,
    LatLngBounds? visibleRegion,
  }) = _MapState;
}
