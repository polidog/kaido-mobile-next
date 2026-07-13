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
            appName: '甲州道中四十四次',
            apiContext: 'koshudo',
            themeColor: Color(0xFF8C5CA8), // 甲州街道の紫

            assetPrefix: 'assets',
            markerHues: {
              '見付': 30, // オレンジ
              '宿場': 270, // 紫
              '一里塚': 120, // 緑
              '名所': 210, // 青
              '浮世絵ポイント': 330, // ピンク
            },
          ),
        ),
      ],
      child: const KaidoApp(),
    ),
  );
}
