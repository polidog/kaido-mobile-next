import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaido_ui/google_maps_bootstrap.dart';
import 'package:kaido_ui/kaido_app.dart';
import 'package:kaido_ui/kaido_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureGoogleMapsApiKey();
  runApp(
    ProviderScope(
      overrides: [
        kaidoConfigProvider.overrideWithValue(
          const KaidoConfig(
            appName: '東海道五十三次',
            apiContext: 'tokaido',
            themeColor: Color(0xFFFF8585), // 東海道の赤

            assetPrefix: 'assets',
            markerHues: {
              '見付': 30, // 宿場の出入り口（オレンジ）
              '宿場': 0, // 宿場（赤）
              '一里塚': 120, // 一里塚（緑）
              '名所': 210, // 名所（青）
              '浮世絵ポイント': 330, // 浮世絵ポイント（ピンク）
            },
          ),
        ),
      ],
      child: const KaidoApp(),
    ),
  );
}
