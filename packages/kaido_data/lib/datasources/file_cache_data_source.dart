import 'dart:convert';
import 'dart:io';

import 'package:kaido_data/models/detour.dart';
import 'package:kaido_data/models/point.dart';
import 'package:kaido_data/models/route_point.dart';
import 'package:path_provider/path_provider.dart';

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

  /// Caches [points] for the given [context].
  Future<void> cachePoints(String context, List<Point> points) async {
    final file = await _fileFor(context, 'points');
    await file.writeAsString(
      jsonEncode(points.map((p) => p.toJson()).toList()),
    );
  }

  /// Reads previously cached points for the given [context], or `null` if
  /// no cache exists or it cannot be parsed.
  Future<List<Point>?> readPoints(String context) async {
    try {
      final file = await _fileFor(context, 'points');
      if (!file.existsSync()) return null;
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Point.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }

  /// Caches [routes] for the given [context].
  Future<void> cacheRoutes(String context, List<RoutePoint> routes) async {
    final file = await _fileFor(context, 'routes');
    await file.writeAsString(
      jsonEncode(routes.map((r) => r.toJson()).toList()),
    );
  }

  /// Reads previously cached routes for the given [context], or `null` if
  /// no cache exists or it cannot be parsed.
  Future<List<RoutePoint>?> readRoutes(String context) async {
    try {
      final file = await _fileFor(context, 'routes');
      if (!file.existsSync()) return null;
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }

  /// Caches [detours] for the given [context].
  Future<void> cacheDetours(String context, List<Detour> detours) async {
    final file = await _fileFor(context, 'detours');
    await file.writeAsString(
      jsonEncode(detours.map((d) => d.toJson()).toList()),
    );
  }

  /// Reads previously cached detours for the given [context], or `null` if
  /// no cache exists or it cannot be parsed.
  Future<List<Detour>?> readDetours(String context) async {
    try {
      final file = await _fileFor(context, 'detours');
      if (!file.existsSync()) return null;
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Detour.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }
}
