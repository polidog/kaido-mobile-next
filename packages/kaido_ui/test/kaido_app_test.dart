import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/kaido_app.dart';
import 'package:kaido_ui/kaido_config.dart';
import 'package:kaido_ui/pages/map_page.dart';
import 'package:kaido_ui/router/kaido_router.dart';

class _FakePoints extends Points {
  @override
  Future<List<Point>> build() async => const [];
}

class _FakeRoutes extends Routes {
  @override
  Future<List<RoutePoint>> build() async => const [];
}

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
        overrides: [
          kaidoConfigProvider.overrideWithValue(config),
          pointsProvider.overrideWith(_FakePoints.new),
          routesProvider.overrideWith(_FakeRoutes.new),
          initialCameraPositionProvider.overrideWith((ref) async => null),
        ],
        child: KaidoApp(router: createKaidoRouter()),
      ),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, config.appName);
    expect(find.byType(MapPage), findsOneWidget);
  });
}
