import 'dart:async';

import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/datasources/file_cache_data_source.dart';
import 'package:kaido_data/datasources/local_bundle_data_source.dart';
import 'package:kaido_data/datasources/remote/routes_remote_data_source.dart';
import 'package:kaido_data/models/route_point.dart';

/// Cache-first repository for [RoutePoint] data.
///
/// Returns file-cached data immediately when available. When the cache is
/// older than [_staleThreshold], a background revalidation syncs fresh data
/// from the remote database (picked up on the next read). When no cache
/// exists — or a remote fetch is forced — fetches from the remote API,
/// falling back to cache/bundle on failure.
class RouteRepository {
  /// Creates a [RouteRepository].
  RouteRepository({
    required RoutesRemoteDataSource remote,
    required FileCacheDataSource fileCache,
    required LocalBundleDataSource bundle,
    required String assetPrefix,
  }) : _remote = remote,
       _fileCache = fileCache,
       _bundle = bundle,
       _assetPrefix = assetPrefix;

  final RoutesRemoteDataSource _remote;
  final FileCacheDataSource _fileCache;
  final LocalBundleDataSource _bundle;
  final String _assetPrefix;

  static const _staleThreshold = Duration(days: 30);

  /// Gets the route coordinates for the given [context].
  ///
  /// Set [forceRemote] to bypass the cache-first path and wait for the
  /// remote API (used by the manual data-update flow).
  Future<List<RoutePoint>> getRoutes(
    String context, {
    bool forceRemote = false,
  }) async {
    if (!forceRemote) {
      final cached = await _fileCache.readRoutes(context);
      if (cached != null && cached.isNotEmpty) {
        if (await _fileCache.isStale(context, 'routes', _staleThreshold)) {
          unawaited(_revalidateCache(context));
        }
        return cached;
      }
    }
    final result = await _remote.fetch(context);
    if (result case ApiSuccess(:final data)) {
      await _fileCache.cacheRoutes(context, data);
      return data;
    }
    return _fallback(context);
  }

  Future<void> _revalidateCache(String context) async {
    final result = await _remote.fetch(context);
    if (result case ApiSuccess(:final data)) {
      try {
        await _fileCache.cacheRoutes(context, data);
      } on Exception {
        // ベストエフォートのバックグラウンド更新なので、失敗は無視する。
      }
    }
  }

  Future<List<RoutePoint>> _fallback(String context) async {
    final cached = await _fileCache.readRoutes(context);
    if (cached != null && cached.isNotEmpty) return cached;
    return _bundle.loadRoutes('$_assetPrefix/json/routes.json');
  }
}
