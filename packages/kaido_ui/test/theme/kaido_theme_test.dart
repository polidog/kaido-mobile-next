import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_ui/theme/kaido_theme.dart';

void main() {
  group('KaidoTheme.light', () {
    test('enables Material 3', () {
      final theme = KaidoTheme.light(seedColor: Colors.blue);
      expect(theme.useMaterial3, isTrue);
    });

    test('derives colorScheme.primary from seedColor', () {
      const seedColor = Colors.blue;
      final theme = KaidoTheme.light(seedColor: seedColor);
      final expectedScheme = ColorScheme.fromSeed(seedColor: seedColor);
      expect(theme.colorScheme.primary, expectedScheme.primary);
    });

    test('applies seedColor to appBarTheme.backgroundColor', () {
      const seedColor = Colors.red;
      final theme = KaidoTheme.light(seedColor: seedColor);
      expect(theme.appBarTheme.backgroundColor, seedColor);
    });

    test('different seed colors produce different color schemes', () {
      final blueTheme = KaidoTheme.light(seedColor: Colors.blue);
      final redTheme = KaidoTheme.light(seedColor: Colors.red);
      expect(
        blueTheme.colorScheme.primary,
        isNot(equals(redTheme.colorScheme.primary)),
      );
    });
  });
}
