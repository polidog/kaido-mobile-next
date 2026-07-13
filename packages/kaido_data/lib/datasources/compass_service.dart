import 'package:flutter_compass/flutter_compass.dart';
import 'package:kaido_data/utils/stream_throttle.dart';

/// Provides access to the device's compass heading.
abstract class CompassService {
  /// A stream of the device's compass heading, in degrees. `null` if the
  /// device does not support the compass sensor.
  Stream<double?> headingStream();
}

/// [CompassService] implementation backed by the `flutter_compass` plugin.
class DeviceCompassService implements CompassService {
  /// センサーは端末によって数十Hzで発火するため、カメラ操作が追いつく
  /// 頻度まで間引く。
  static const _throttleInterval = Duration(milliseconds: 200);

  @override
  Stream<double?> headingStream() =>
      FlutterCompass.events
          ?.map((event) => event.heading)
          .transform(throttleLatest(_throttleInterval)) ??
      const Stream.empty();
}
