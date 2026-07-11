import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaido_ui/kaido_app.dart';
import 'package:kaido_ui/kaido_config.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        kaidoConfigProvider.overrideWithValue(
          const KaidoConfig(
            appName: '中山道六十九次',
            apiContext: 'nakasendo',
            themeColor: Color(0xFFECB404),
            assetPrefix: 'assets',
          ),
        ),
      ],
      child: const KaidoApp(),
    ),
  );
}
