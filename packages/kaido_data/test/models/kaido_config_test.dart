import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/models/kaido_config.dart';

void main() {
  group('KaidoConfig', () {
    const config = KaidoConfig(
      appName: '東海道五十三次',
      apiContext: 'tokaido',
      themeColor: Color(0xFFECB404),
      assetPrefix: 'assets',
    );

    test('supports value equality', () {
      const other = KaidoConfig(
        appName: '東海道五十三次',
        apiContext: 'tokaido',
        themeColor: Color(0xFFECB404),
        assetPrefix: 'assets',
      );

      expect(config, other);
    });

    test('copyWith overrides only specified fields', () {
      final updated = config.copyWith(appName: '中山道六十九次');

      expect(updated.appName, '中山道六十九次');
      expect(updated.apiContext, config.apiContext);
      expect(updated.themeColor, config.themeColor);
      expect(updated.assetPrefix, config.assetPrefix);
    });
  });
}
