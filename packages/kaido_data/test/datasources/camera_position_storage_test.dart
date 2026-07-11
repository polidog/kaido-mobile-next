import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/datasources/camera_position_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesCameraPositionStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = SharedPreferencesCameraPositionStorage();
  });

  group('SharedPreferencesCameraPositionStorage', () {
    test('write then read round trips the camera position', () async {
      const position = CameraPosition(
        target: LatLng(35.6812, 139.7671),
        zoom: 14,
        bearing: 45,
        tilt: 10,
      );

      await storage.write('tokaido', position);
      final result = await storage.read('tokaido');

      expect(result?.target, position.target);
      expect(result?.zoom, position.zoom);
      expect(result?.bearing, position.bearing);
      expect(result?.tilt, position.tilt);
    });

    test('read returns null when nothing has been persisted', () async {
      final result = await storage.read('missing');

      expect(result, isNull);
    });

    test('read returns null for malformed JSON', () async {
      SharedPreferences.setMockInitialValues({
        'camera_position_broken': 'not valid json',
      });
      storage = SharedPreferencesCameraPositionStorage();

      final result = await storage.read('broken');

      expect(result, isNull);
    });

    test('read returns null when required fields are missing', () async {
      SharedPreferences.setMockInitialValues({
        'camera_position_partial': '{"lat": 35.6}',
      });
      storage = SharedPreferencesCameraPositionStorage();

      final result = await storage.read('partial');

      expect(result, isNull);
    });

    test('read scopes values by context', () async {
      const position = CameraPosition(target: LatLng(1, 2), zoom: 5);
      await storage.write('tokaido', position);

      final result = await storage.read('nakasendo');

      expect(result, isNull);
    });
  });
}
