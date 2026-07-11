import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kaido_config.freezed.dart';

/// Per-app configuration injected via `kaidoConfigProvider`.
@freezed
abstract class KaidoConfig with _$KaidoConfig {
  /// Creates a [KaidoConfig].
  const factory KaidoConfig({
    required String appName,
    required String apiContext,
    required Color themeColor,
    required String assetPrefix,
    String? fontFamily,
  }) = _KaidoConfig;
}
