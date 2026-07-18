import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/datasources/camera_position_storage.dart';
import 'package:kaido_data/datasources/compass_service.dart';
import 'package:kaido_data/datasources/location_service.dart';
import 'package:kaido_data/providers/kaido_config_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_providers.g.dart';

/// Provides the [LocationService] used to read the device's GPS location.
@riverpod
LocationService locationService(Ref ref) => GeolocatorLocationService();

/// Provides the [CompassService] used to read the device's compass heading.
@riverpod
CompassService compassService(Ref ref) => DeviceCompassService();

/// Provides the [CameraPositionStorage] used to persist the map's camera
/// position between sessions.
@riverpod
CameraPositionStorage cameraPositionStorage(Ref ref) =>
    SharedPreferencesCameraPositionStorage();

/// Streams the device's current [Position].
@riverpod
Stream<Position> currentPosition(Ref ref) =>
    ref.watch(locationServiceProvider).positionStream();

/// Streams the device's current compass heading, in degrees.
@riverpod
Stream<double?> compassHeading(Ref ref) =>
    ref.watch(compassServiceProvider).headingStream();

/// Reads the persisted [CameraPosition] for the current app's API context,
/// or `null` if none has been saved yet.
///
/// ナビモード(3Dヘディング)中にアプリを終了してもチルトは持ち越さず、
/// 起動時は常に平面(2D)の地図で開く。
@riverpod
Future<CameraPosition?> initialCameraPosition(Ref ref) async {
  final config = ref.watch(kaidoConfigProvider);
  final storage = ref.watch(cameraPositionStorageProvider);
  final saved = await storage.read(config.apiContext);
  if (saved == null || saved.tilt == 0) return saved;
  return CameraPosition(
    target: saved.target,
    zoom: saved.zoom,
    bearing: saved.bearing,
  );
}
