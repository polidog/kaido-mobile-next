import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_ui/kaido_app.dart';
import 'package:kaido_ui/kaido_config.dart';
import 'package:kaido_ui/pages/map_page.dart';
import 'package:kaido_ui/router/kaido_router.dart';

void main() {
  testWidgets('KaidoApp uses KaidoConfig.appName as title and shows MapPage', (
    tester,
  ) async {
    const config = KaidoConfig(
      appName: '東海道五十三次',
      apiContext: 'tokaido',
      themeColor: Color(0xFFECB404),
      assetPrefix: 'assets',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [kaidoConfigProvider.overrideWithValue(config)],
        child: KaidoApp(router: createKaidoRouter()),
      ),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, config.appName);
    expect(find.byType(MapPage), findsOneWidget);
  });
}
