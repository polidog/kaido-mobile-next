import 'dart:async';
import 'dart:io';

import 'package:kaido_api/kaido_api.dart';
import 'package:libsql_dart/libsql_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Connection settings for the Turso embedded replica.
class TursoSettings {
  /// Creates a [TursoSettings].
  const TursoSettings({required this.authToken, this.syncUrlOverride});

  /// Read-only auth token for the Turso databases, injected at build time
  /// via `--dart-define-from-file` (`TURSO_AUTH_TOKEN`).
  final String authToken;

  /// Optional fixed sync URL. When set, the `/api/v1/maps` lookup is
  /// skipped entirely (useful for tests and local development).
  final String? syncUrlOverride;
}

/// Manages the lifecycle of the Turso embedded replica database for a map
/// context (e.g. `tokaido`).
///
/// The replica is a local SQLite file that is synced from the remote Turso
/// database. Reads always hit the local file, so the app works offline once
/// the first sync has completed. The remote database URL is resolved via
/// the `/api/v1/maps` endpoint and cached in [SharedPreferences] so that
/// later cold starts do not require the API to be reachable.
class TursoMapDatabase {
  /// Creates a [TursoMapDatabase].
  TursoMapDatabase({
    required KaidoApiService apiService,
    required TursoSettings settings,
  }) : _apiService = apiService,
       _settings = settings;

  final KaidoApiService _apiService;
  final TursoSettings _settings;

  final Map<String, Future<LibsqlClient>> _clients = {};
  final Map<String, Future<void>> _inflightSyncs = {};
  final Map<String, DateTime> _lastSyncedAt = {};

  /// この間隔以内の再同期要求はスキップする（points/routes/detours の
  /// 3プロバイダが起動時に並行 fetch しても同期は1回で済むように）。
  static const _syncThrottle = Duration(seconds: 30);

  static String _urlPrefsKey(String context) => 'turso_sync_url_$context';

  /// Opens (and caches) the replica client for [context].
  Future<LibsqlClient> open(String context) {
    return _clients.putIfAbsent(context, () async {
      try {
        return await _connect(context);
      } on Object {
        // 失敗した Future をキャッシュすると再起動まで復旧できないため外す。
        unawaited(_clients.remove(context));
        rethrow;
      }
    });
  }

  Future<LibsqlClient> _connect(String context) async {
    final syncUrl = await _resolveSyncUrl(context);
    final dir = await getApplicationSupportDirectory();
    final tursoDir = Directory('${dir.path}/turso');
    if (!tursoDir.existsSync()) {
      tursoDir.createSync(recursive: true);
    }
    final client = LibsqlClient.replica(
      '${tursoDir.path}/$context.db',
      syncUrl: syncUrl,
      authToken: _settings.authToken,
    );
    await client.connect();
    return client;
  }

  /// Syncs the replica for [context] with the remote database.
  ///
  /// Concurrent calls for the same [context] share a single in-flight
  /// sync, and calls within [_syncThrottle] of the last successful sync
  /// are no-ops. Throws when the sync fails (e.g. offline); callers
  /// decide whether stale local data is acceptable.
  Future<void> sync(String context) {
    final last = _lastSyncedAt[context];
    if (last != null && DateTime.now().difference(last) < _syncThrottle) {
      return Future.value();
    }
    return _inflightSyncs.putIfAbsent(context, () async {
      try {
        final client = await open(context);
        await client.sync();
        _lastSyncedAt[context] = DateTime.now();
      } finally {
        unawaited(_inflightSyncs.remove(context));
      }
    });
  }

  /// Runs a read-only [sql] query against the replica for [context].
  Future<List<Map<String, dynamic>>> query(
    String context,
    String sql, {
    List<dynamic>? positional,
  }) async {
    final client = await open(context);
    return client.query(sql, positional: positional);
  }

  Future<String> _resolveSyncUrl(String context) async {
    final override = _settings.syncUrlOverride;
    if (override != null && override.isNotEmpty) return override;

    // キャッシュ済み URL を優先する。API 呼び出しを待たないことで
    // オフライン時もタイムアウト待ちなしで起動できる（URL が変わる
    // ことは稀で、変わった場合は sync 失敗後の再起動で再解決される）。
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_urlPrefsKey(context));
    if (cached != null && cached.isNotEmpty) return cached;

    final result = await _apiService.getMaps();
    if (result case ApiSuccess(:final data)) {
      final map = data
          .cast<MapSummaryDto?>()
          .firstWhere((m) => m?.aliasName == context, orElse: () => null);
      final url = map?.databaseUrl;
      if (url != null && url.isNotEmpty) {
        await prefs.setString(_urlPrefsKey(context), url);
        return url;
      }
    }
    throw StateError(
      'Turso database URL could not be resolved for context "$context"',
    );
  }

  /// Closes all open replica clients.
  Future<void> dispose() async {
    for (final client in _clients.values) {
      try {
        await (await client).dispose();
      } on Object {
        // dispose 失敗は無視する（アプリ終了時のベストエフォート）。
      }
    }
    _clients.clear();
  }
}
