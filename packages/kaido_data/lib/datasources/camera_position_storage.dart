import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and restores the map's last [CameraPosition], keyed by API
/// context, so the map reopens where the user left it.
abstract class CameraPositionStorage {
  /// Reads the previously persisted [CameraPosition] for [context], or
  /// `null` if none exists or it cannot be parsed.
  Future<CameraPosition?> read(String context);

  /// Persists [position] for the given [context].
  Future<void> write(String context, CameraPosition position);
}

/// [CameraPositionStorage] implementation backed by [SharedPreferences].
class SharedPreferencesCameraPositionStorage implements CameraPositionStorage {
  String _keyFor(String context) => 'camera_position_$context';

  @override
  Future<CameraPosition?> read(String context) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(context));
    if (raw == null) return null;

    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;

    final lat = decoded['lat'];
    final lng = decoded['lng'];
    final zoom = decoded['zoom'];
    final bearing = decoded['bearing'];
    final tilt = decoded['tilt'];
    if (lat is! num ||
        lng is! num ||
        zoom is! num ||
        bearing is! num ||
        tilt is! num) {
      return null;
    }

    return CameraPosition(
      target: LatLng(lat.toDouble(), lng.toDouble()),
      zoom: zoom.toDouble(),
      bearing: bearing.toDouble(),
      tilt: tilt.toDouble(),
    );
  }

  @override
  Future<void> write(String context, CameraPosition position) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      'lat': position.target.latitude,
      'lng': position.target.longitude,
      'zoom': position.zoom,
      'bearing': position.bearing,
      'tilt': position.tilt,
    });
    await prefs.setString(_keyFor(context), encoded);
  }
}
