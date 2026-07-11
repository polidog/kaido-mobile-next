import 'package:geolocator/geolocator.dart';

/// Provides access to the device's GPS location.
abstract class LocationService {
  /// Ensures location permission is granted, requesting it if necessary.
  ///
  /// Checks whether location services are enabled, then checks (and
  /// requests, if needed) the app's location permission.
  Future<LocationPermission> ensurePermission();

  /// Returns the device's current [Position].
  Future<Position> getCurrentPosition();

  /// A stream of the device's [Position] as it changes.
  Stream<Position> positionStream();
}

/// [LocationService] implementation backed by the `geolocator` plugin.
class GeolocatorLocationService implements LocationService {
  @override
  Future<LocationPermission> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermission.denied;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  @override
  Future<Position> getCurrentPosition() => Geolocator.getCurrentPosition();

  @override
  Stream<Position> positionStream() => Geolocator.getPositionStream();
}
