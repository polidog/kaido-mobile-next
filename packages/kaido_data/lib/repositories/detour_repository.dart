import 'dart:async';

import 'package:kaido_api/kaido_api.dart';
import 'package:kaido_data/datasources/file_cache_data_source.dart';
import 'package:kaido_data/datasources/local_bundle_data_source.dart';
import 'package:kaido_data/datasources/remote/detours_remote_data_source.dart';
import 'package:kaido_data/models/detour.dart';

/// Cache-first repository for [Detour] data.
///
/// Returns file-cached data immediately when available, while triggering a
/// background revalidation to keep the cache fresh for subsequent reads.
/// When no cache exists — or a remote fetch is forced — fetches from the
/// remote API, falling back to cache/bundle on failure.
class DetourRepository {
  /// Creates a [DetourRepository].
  DetourRepository({
    required DetoursRemoteDataSource remote,
    required FileCacheDataSource fileCache,
    required LocalBundleDataSource bundle,
    required String assetPrefix,
  }) : _remote = remote,
       _fileCache = fileCache,
       _bundle = bundle,
       _assetPrefix = assetPrefix;

  final DetoursRemoteDataSource _remote;
  final FileCacheDataSource _fileCache;
  final LocalBundleDataSource _bundle;
  final String _assetPrefix;

  /// Gets the detour route coordinates for the given [context].
  ///
  /// Set [forceRemote] to bypass the cache-first path and wait for the
  /// remote API (used by the manual data-update flow).
  Future<List<Detour>> getDetours(
    String context, {
    bool forceRemote = false,
  }) async {
    if (!forceRemote) {
      final cached = await _fileCache.readDetours(context);
      if (cached != null && cached.isNotEmpty) {
        unawaited(_revalidateCache(context));
        return cached;
      }
    }
    final result = await _remote.fetch(context);
    if (result case ApiSuccess(:final data)) {
      await _fileCache.cacheDetours(context, data);
      return data;
    }
    return _fallback(context);
  }

  Future<void> _revalidateCache(String context) async {
    final result = await _remote.fetch(context);
    if (result case ApiSuccess(:final data)) {
      try {
        await _fileCache.cacheDetours(context, data);
      } on Exception {
        // ベストエフォートのバックグラウンド更新なので、失敗は無視する。
      }
    }
  }

  Future<List<Detour>> _fallback(String context) async {
    final cached = await _fileCache.readDetours(context);
    if (cached != null && cached.isNotEmpty) return cached;
    return _bundle.loadDetours('$_assetPrefix/json/detours.json');
  }
}
