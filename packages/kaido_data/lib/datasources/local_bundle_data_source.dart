import 'dart:convert';

import 'package:kaido_data/datasources/asset_loader.dart';
import 'package:kaido_data/models/detour.dart';
import 'package:kaido_data/models/point.dart';
import 'package:kaido_data/models/route_point.dart';

/// Loads fallback domain data bundled with the app as JSON assets.
class LocalBundleDataSource {
  /// Creates a [LocalBundleDataSource].
  const LocalBundleDataSource(this._assetLoader);

  final AssetLoader _assetLoader;

  /// Loads a list of [Point]s from the JSON asset at [assetKey].
  Future<List<Point>> loadPoints(String assetKey) async {
    final raw = await _assetLoader.loadString(assetKey);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Point.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Loads a list of [RoutePoint]s from the JSON asset at [assetKey].
  Future<List<RoutePoint>> loadRoutes(String assetKey) async {
    final raw = await _assetLoader.loadString(assetKey);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Loads a list of [Detour]s from the JSON asset at [assetKey].
  Future<List<Detour>> loadDetours(String assetKey) async {
    final raw = await _assetLoader.loadString(assetKey);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Detour.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
