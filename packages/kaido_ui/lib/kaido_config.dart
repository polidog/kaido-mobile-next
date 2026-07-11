import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Per-app configuration injected via [kaidoConfigProvider].
///
// TODO(kaido): Replace with the freezed model from `kaido_data` once Phase 3
// lands.
class KaidoConfig {
  /// Creates a [KaidoConfig].
  const KaidoConfig({
    required this.appName,
    required this.apiContext,
    required this.themeColor,
    required this.assetPrefix,
    this.fontFamily,
  });

  /// Display name of the app (e.g. '東海道五十三次').
  final String appName;

  /// API context identifier used by `kaido_api` (e.g. 'tokaido').
  final String apiContext;

  /// Seed color used to derive the app's color scheme.
  final Color themeColor;

  /// Asset path prefix for app-specific bundled assets.
  final String assetPrefix;

  /// Optional font family name for the app's theme.
  final String? fontFamily;
}

/// Provides the current app's [KaidoConfig].
///
/// Must be overridden by each app's `ProviderScope`.
final kaidoConfigProvider = Provider<KaidoConfig>(
  (ref) => throw UnimplementedError(
    'kaidoConfigProvider must be overridden by the app',
  ),
);
