import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/pages/map_page.dart';
import 'package:kaido_ui/router/kaido_router.dart';

const _testConfig = KaidoConfig(
  appName: 'テストアプリ',
  apiContext: 'tokaido',
  themeColor: Color(0xFFECB404),
  assetPrefix: 'assets',
);

class _FakePoints extends Points {
  @override
  Future<List<Point>> build() async => const [];
}

void main() {
  testWidgets('SplashPage navigates to MapPage after 3 seconds', (
    tester,
  ) async {
    final router = createKaidoRouter(initialLocation: '/splash');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          kaidoConfigProvider.overrideWithValue(_testConfig),
          pointsProvider.overrideWith(_FakePoints.new),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.byType(MapPage), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(MapPage), findsOneWidget);
  });
}
