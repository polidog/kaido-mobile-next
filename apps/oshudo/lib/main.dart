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
            appName: '奥州道中十次',
            apiContext: 'oshudo',
            themeColor: Color(0xFFECB404),
            assetPrefix: 'assets',
          ),
        ),
      ],
      child: const KaidoApp(),
    ),
  );
}
