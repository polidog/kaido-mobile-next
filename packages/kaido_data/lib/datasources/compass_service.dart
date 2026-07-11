import 'package:flutter_compass/flutter_compass.dart';

/// Provides access to the device's compass heading.
abstract class CompassService {
  /// A stream of the device's compass heading, in degrees. `null` if the
  /// device does not support the compass sensor.
  Stream<double?> headingStream();
}

/// [CompassService] implementation backed by the `flutter_compass` plugin.
class DeviceCompassService implements CompassService {
  @override
  Stream<double?> headingStream() =>
      FlutterCompass.events?.map((event) => event.heading) ??
      const Stream.empty();
}
