import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/pages/contact_map_page.dart';
import 'package:kaido_ui/pages/contact_page.dart';
import 'package:kaido_ui/pages/copyright_page.dart';
import 'package:kaido_ui/pages/gokaido_page.dart';
import 'package:kaido_ui/pages/help_page.dart';
import 'package:kaido_ui/pages/image_page.dart';
import 'package:kaido_ui/pages/info_page.dart';
import 'package:kaido_ui/pages/introduction_page.dart';
import 'package:kaido_ui/pages/map_page.dart';
import 'package:kaido_ui/pages/settings_page.dart';
import 'package:kaido_ui/pages/splash_page.dart';
import 'package:kaido_ui/router/kaido_router.dart';

import '../helpers/fake_assets.dart';

/// Test double that provides a fixed, immediately-available points list so
/// widget tests don't hit the real repository chain.
class _FakePoints extends Points {
  @override
  Future<List<Point>> build() async => const [
    Point(
      id: 42,
      title: 'テスト地点',
      lat: 35,
      lng: 139,
      description: '説明',
      category: 'category',
    ),
  ];
}

/// Test double that provides a fixed, immediately-available empty routes
/// list so widget tests don't hit the real repository chain.
class _FakeRoutes extends Routes {
  @override
  Future<List<RoutePoint>> build() async => const [];
}

/// Test double that provides a fixed, immediately-available empty detours
/// list so widget tests don't hit the real repository chain.
class _FakeDetours extends Detours {
  @override
  Future<List<Detour>> build() async => const [];
}

const _testConfig = KaidoConfig(
  appName: 'テストアプリ',
  apiContext: 'tokaido',
  themeColor: Color(0xFFECB404),
  assetPrefix: 'assets',
);

void main() {
  final overrides = [
    kaidoConfigProvider.overrideWithValue(_testConfig),
    pointsProvider.overrideWith(_FakePoints.new),
    routesProvider.overrideWith(_FakeRoutes.new),
    detoursProvider.overrideWith(_FakeDetours.new),
    initialCameraPositionProvider.overrideWith((ref) async => null),
    assetLoaderProvider.overrideWithValue(FakeAssetLoader()),
  ];

  Future<void> pumpAt(WidgetTester tester, String location) async {
    final router = createKaidoRouter(initialLocation: location);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('/ resolves to MapPage', (tester) async {
    await pumpAt(tester, '/');
    expect(find.byType(MapPage), findsOneWidget);
  });

  testWidgets('/info/:id resolves to InfoPage', (tester) async {
    await pumpAt(tester, '/info/42');
    final infoPage = tester.widget<InfoPage>(find.byType(InfoPage));
    expect(infoPage.id, '42');
  });

  testWidgets('/info/:id/image resolves to ImagePage', (tester) async {
    await pumpAt(tester, '/info/42/image');
    final imagePage = tester.widget<ImagePage>(find.byType(ImagePage));
    expect(imagePage.id, '42');
  });

  testWidgets('/settings resolves to SettingsPage', (tester) async {
    await pumpAt(tester, '/settings');
    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('/contact resolves to ContactPage', (tester) async {
    await pumpAt(tester, '/contact');
    expect(find.byType(ContactPage), findsOneWidget);
  });

  testWidgets('/contact/map resolves to ContactMapPage', (tester) async {
    await pumpAt(tester, '/contact/map');
    expect(find.byType(ContactMapPage), findsOneWidget);
  });

  testWidgets('/intro resolves to IntroductionPage', (tester) async {
    await pumpAt(tester, '/intro');
    expect(find.byType(IntroductionPage), findsOneWidget);
  });

  testWidgets('/help resolves to HelpPage', (tester) async {
    await pumpAt(tester, '/help');
    expect(find.byType(HelpPage), findsOneWidget);
  });

  testWidgets('/gokaido resolves to GokaidoPage', (tester) async {
    await pumpAt(tester, '/gokaido');
    expect(find.byType(GokaidoPage), findsOneWidget);
  });

  testWidgets('/copyright resolves to CopyrightPage', (tester) async {
    await pumpAt(tester, '/copyright');
    expect(find.byType(CopyrightPage), findsOneWidget);
  });

  testWidgets('/splash resolves to SplashPage', (tester) async {
    final router = createKaidoRouter(initialLocation: '/splash');
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    // pump() only — advancing time would fire the splash's navigation
    // timers and move away from SplashPage.
    await tester.pump();
    expect(find.byType(SplashPage), findsOneWidget);
  });

  testWidgets('unknown route triggers errorBuilder', (tester) async {
    await pumpAt(tester, '/does-not-exist');
    expect(find.text('エラー'), findsOneWidget);
  });
}
