import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaido_data/models/kaido_config.dart';

/// Provides the current app's [KaidoConfig].
///
/// Must be overridden by each app's `ProviderScope`.
final kaidoConfigProvider = Provider<KaidoConfig>(
  (ref) => throw UnimplementedError(
    'kaidoConfigProvider must be overridden by the app',
  ),
);
