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
      appBarTheme: AppBarTheme(
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
