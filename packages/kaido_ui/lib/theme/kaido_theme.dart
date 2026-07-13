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
      // アプリのテーマカラーを薄く敷いた背景色（街道ごとに変わる）
      scaffoldBackgroundColor: Color.alphaBlend(
        seedColor.withValues(alpha: 0.08),
        Colors.white,
      ),
      // カード（BOX）は背景ティントに対して白で浮かせる
      cardTheme: const CardThemeData(color: Colors.white),
      // ヘッダはアプリのテーマカラー
      appBarTheme: AppBarTheme(
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
