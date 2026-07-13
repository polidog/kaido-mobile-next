import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kaido_data/datasources/asset_loader.dart';
import 'package:kaido_data/models/detour.dart';
import 'package:kaido_data/models/point.dart';
import 'package:kaido_data/models/route_point.dart';

// JSON 変換は街道によって 1 万要素を超えるため、UI スレッドを塞がないよう
// compute でワーカーアイソレートに逃がす。compute に渡す関数はトップレベル
// である必要がある。

List<Point> _decodePoints(String raw) => (jsonDecode(raw) as List<dynamic>)
    .map((e) => Point.fromJson(e as Map<String, dynamic>))
    .toList();

List<RoutePoint> _decodeRoutes(String raw) => (jsonDecode(raw) as List<dynamic>)
    .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
    .toList();

List<Detour> _decodeDetours(String raw) => (jsonDecode(raw) as List<dynamic>)
    .map((e) => Detour.fromJson(e as Map<String, dynamic>))
    .toList();

/// Loads fallback domain data bundled with the app as JSON assets.
class LocalBundleDataSource {
  /// Creates a [LocalBundleDataSource].
  const LocalBundleDataSource(this._assetLoader);

  final AssetLoader _assetLoader;

  /// Loads a list of [Point]s from the JSON asset at [assetKey].
  Future<List<Point>> loadPoints(String assetKey) async {
    final raw = await _assetLoader.loadString(assetKey);
    return compute(_decodePoints, raw);
  }

  /// Loads a list of [RoutePoint]s from the JSON asset at [assetKey].
  Future<List<RoutePoint>> loadRoutes(String assetKey) async {
    final raw = await _assetLoader.loadString(assetKey);
    return compute(_decodeRoutes, raw);
  }

  /// Loads a list of [Detour]s from the JSON asset at [assetKey].
  Future<List<Detour>> loadDetours(String assetKey) async {
    final raw = await _assetLoader.loadString(assetKey);
    return compute(_decodeDetours, raw);
  }
}
