import 'package:flutter/material.dart';

/// Provides the shared theme for all Kaido apps.
class KaidoTheme {
  const KaidoTheme._();

  /// Builds the light [ThemeData] for a given [seedColor].
  static ThemeData light({required Color seedColor, String? fontFamily}) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      // 旧アプリと同じ薄いブルーグレーの背景（全アプリ共通）
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
