import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/pages/contact_map_page.dart';
import 'package:kaido_ui/pages/contact_page.dart';
import 'package:kaido_ui/pages/copyright_page.dart';
import 'package:kaido_ui/pages/html_page.dart';
import 'package:kaido_ui/pages/image_page.dart';
import 'package:kaido_ui/pages/info_page.dart';
import 'package:kaido_ui/pages/map_page.dart';
import 'package:kaido_ui/pages/settings_page.dart';
import 'package:kaido_ui/pages/splash_page.dart';
import 'package:kaido_ui/router/kaido_router.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

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

class _FakeAssetLoader implements AssetLoader {
  @override
  Future<String> loadString(String key) async => '<html><body>fake</body></html>';
}

class _FakePlatformWebViewController extends PlatformWebViewController {
  _FakePlatformWebViewController(super.params) : super.implementation();

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}
}

class _FakePlatformWebViewWidget extends PlatformWebViewWidget {
  _FakePlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) =>
      _FakePlatformWebViewController(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) =>
      _FakePlatformWebViewWidget(params);
}

const _testConfig = KaidoConfig(
  appName: 'テストアプリ',
  apiContext: 'tokaido',
  themeColor: Color(0xFFECB404),
  assetPrefix: 'assets',
);

void main() {
  setUp(() {
    WebViewPlatform.instance = _FakeWebViewPlatform();
  });

  final overrides = [
    kaidoConfigProvider.overrideWithValue(_testConfig),
    pointsProvider.overrideWith(_FakePoints.new),
    routesProvider.overrideWith(_FakeRoutes.new),
    initialCameraPositionProvider.overrideWith((ref) async => null),
    assetLoaderProvider.overrideWithValue(_FakeAssetLoader()),
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

  testWidgets('/html/:page resolves to HtmlPage', (tester) async {
    await pumpAt(tester, '/html/help');
    final htmlPage = tester.widget<HtmlPage>(find.byType(HtmlPage));
    expect(htmlPage.page, 'help');
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
    // pump() only — pumpAndSettle would trigger the 3-second Timer
    // and navigate away from SplashPage.
    await tester.pump();
    expect(find.byType(SplashPage), findsOneWidget);
  });

  testWidgets('unknown route triggers errorBuilder', (tester) async {
    await pumpAt(tester, '/does-not-exist');
    expect(find.text('エラー'), findsOneWidget);
  });
}
