import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kaido_data/models/detour.dart';
import 'package:kaido_data/models/point.dart';
import 'package:kaido_data/models/route_point.dart';
import 'package:path_provider/path_provider.dart';

// JSON 変換は街道によって 1 万要素を超えるため、UI スレッドを塞がないよう
// compute でワーカーアイソレートに逃がす。compute に渡す関数はトップレベル
// である必要がある。デコード失敗は null で表現する（アイソレート境界を
// 例外が越えると型が保てないため）。

List<Point>? _decodePoints(String raw) {
  try {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Point.fromJson(e as Map<String, dynamic>))
        .toList();
  } on FormatException {
    return null;
  }
}

String _encodePoints(List<Point> points) =>
    jsonEncode(points.map((p) => p.toJson()).toList());

List<RoutePoint>? _decodeRoutes(String raw) {
  try {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
        .toList();
  } on FormatException {
    return null;
  }
}

String _encodeRoutes(List<RoutePoint> routes) =>
    jsonEncode(routes.map((r) => r.toJson()).toList());

List<Detour>? _decodeDetours(String raw) {
  try {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Detour.fromJson(e as Map<String, dynamic>))
        .toList();
  } on FormatException {
    return null;
  }
}

String _encodeDetours(List<Detour> detours) =>
    jsonEncode(detours.map((d) => d.toJson()).toList());

/// Caches domain data to local files, keyed by API context, so the app can
/// work offline after the first successful fetch.
class FileCacheDataSource {
  /// Creates a [FileCacheDataSource].
  ///
  /// [directoryResolver] can be overridden in tests to avoid touching the
  /// real filesystem's application documents directory.
  FileCacheDataSource({Future<Directory> Function()? directoryResolver})
    : _directoryResolver =
          directoryResolver ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directoryResolver;

  Future<File> _fileFor(String context, String name) async {
    final dir = await _directoryResolver();
    return File('${dir.path}/${context}_$name.json');
  }

  Future<void> _write(String context, String name, String encoded) async {
    final file = await _fileFor(context, name);
    await file.writeAsString(encoded);
  }

  Future<List<T>?> _read<T>(
    String context,
    String name,
    List<T>? Function(String) decode,
  ) async {
    try {
      final file = await _fileFor(context, name);
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      return await compute(decode, raw);
    } on FileSystemException {
      return null;
    }
  }

  /// Caches [points] for the given [context].
  Future<void> cachePoints(String context, List<Point> points) async =>
      _write(context, 'points', await compute(_encodePoints, points));

  /// Reads previously cached points for the given [context], or `null` if
  /// no cache exists or it cannot be parsed.
  Future<List<Point>?> readPoints(String context) =>
      _read(context, 'points', _decodePoints);

  /// Caches [routes] for the given [context].
  Future<void> cacheRoutes(String context, List<RoutePoint> routes) async =>
      _write(context, 'routes', await compute(_encodeRoutes, routes));

  /// Reads previously cached routes for the given [context], or `null` if
  /// no cache exists or it cannot be parsed.
  Future<List<RoutePoint>?> readRoutes(String context) =>
      _read(context, 'routes', _decodeRoutes);

  /// Caches [detours] for the given [context].
  Future<void> cacheDetours(String context, List<Detour> detours) async =>
      _write(context, 'detours', await compute(_encodeDetours, detours));

  /// Reads previously cached detours for the given [context], or `null` if
  /// no cache exists or it cannot be parsed.
  Future<List<Detour>?> readDetours(String context) =>
      _read(context, 'detours', _decodeDetours);

  /// Returns `true` if the cache file for [context]/[name] is older than
  /// [maxAge], or if it does not exist.
  Future<bool> isStale(String context, String name, Duration maxAge) async {
    try {
      final file = await _fileFor(context, name);
      if (!await file.exists()) return true;
      final modified = await file.lastModified();
      return DateTime.now().difference(modified) > maxAge;
    } on FileSystemException {
      return true;
    }
  }
}
