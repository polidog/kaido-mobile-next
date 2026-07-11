import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/datasources/file_cache_data_source.dart';
import 'package:kaido_data/datasources/local_bundle_data_source.dart';
import 'package:kaido_data/datasources/remote/points_remote_data_source.dart';
import 'package:kaido_data/models/point.dart';

/// Offline-first repository for [Point] data.
///
/// Attempts a remote fetch first, caching the result to disk. If the
/// remote fetch fails, falls back to the file cache, and finally to the
/// bundled JSON asset.
class PointRepository {
  /// Creates a [PointRepository].
  PointRepository({
    required PointsRemoteDataSource remote,
    required FileCacheDataSource fileCache,
    required LocalBundleDataSource bundle,
    required String assetPrefix,
  }) : _remote = remote,
       _fileCache = fileCache,
       _bundle = bundle,
       _assetPrefix = assetPrefix;

  final PointsRemoteDataSource _remote;
  final FileCacheDataSource _fileCache;
  final LocalBundleDataSource _bundle;
  final String _assetPrefix;

  /// Gets the points for the given [context], preferring the remote API and
  /// falling back to cache/bundle on failure.
  Future<List<Point>> getPoints(String context) async {
    final result = await _remote.fetch(context);
    if (result case ApiSuccess(:final data)) {
      await _fileCache.cachePoints(context, data);
      return data;
    }
    return _fallback(context);
  }

  Future<List<Point>> _fallback(String context) async {
    final cached = await _fileCache.readPoints(context);
    if (cached != null && cached.isNotEmpty) return cached;
    return _bundle.loadPoints('$_assetPrefix/json/points.json');
  }
}
