import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/router/kaido_route_paths.dart';
import 'package:kaido_ui/widgets/bottom_bar.dart';

const _testConfig = KaidoConfig(
  appName: 'テストアプリ',
  apiContext: 'tokaido',
  themeColor: Color(0xFFECB404),
  assetPrefix: 'assets',
);

/// Test double that records permission requests instead of touching the
/// real location plugin.
class _FakeLocationService implements LocationService {
  _FakeLocationService({this.permissionResult = LocationPermission.always});

  final LocationPermission permissionResult;
  int ensurePermissionCallCount = 0;

  @override
  Future<LocationPermission> ensurePermission() async {
    ensurePermissionCallCount++;
    return permissionResult;
  }

  @override
  Future<Position> getCurrentPosition() => throw UnimplementedError();

  @override
  Stream<Position> positionStream() => const Stream.empty();
}

void main() {
  late _FakeLocationService fakeLocationService;

  Widget buildApp({_FakeLocationService? locationService}) {
    final svc = locationService ?? fakeLocationService;
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(bottomNavigationBar: BottomBar()),
        ),
        GoRoute(
          path: KaidoRoutePaths.settings,
          builder: (context, state) =>
              const Scaffold(body: Text('設定画面')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        kaidoConfigProvider.overrideWithValue(_testConfig),
        locationServiceProvider.overrideWithValue(svc),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Color? iconColor(WidgetTester tester, IconData icon) {
    return tester.widget<Icon>(find.byIcon(icon)).color;
  }

  setUp(() {
    fakeLocationService = _FakeLocationService();
  });

  testWidgets('GPS button requests permission and highlights when active', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    expect(iconColor(tester, Icons.navigation), Colors.grey);

    await tester.tap(find.byIcon(Icons.navigation));
    await tester.pumpAndSettle();

    expect(fakeLocationService.ensurePermissionCallCount, 1);
    expect(iconColor(tester, Icons.navigation), isNot(Colors.grey));

    await tester.tap(find.byIcon(Icons.navigation));
    await tester.pumpAndSettle();

    expect(iconColor(tester, Icons.navigation), Colors.grey);
  });

  testWidgets('GPS button shows SnackBar when permission denied', (
    tester,
  ) async {
    final deniedService =
        _FakeLocationService(permissionResult: LocationPermission.denied);
    await tester.pumpWidget(buildApp(locationService: deniedService));

    await tester.tap(find.byIcon(Icons.navigation));
    await tester.pumpAndSettle();

    expect(find.text('位置情報の権限が必要です'), findsOneWidget);
    expect(iconColor(tester, Icons.navigation), Colors.grey);
  });

  testWidgets(
    'GPS button shows SnackBar with settings action when denied forever',
    (tester) async {
      final deniedService = _FakeLocationService(
        permissionResult: LocationPermission.deniedForever,
      );
      await tester.pumpWidget(buildApp(locationService: deniedService));

      await tester.tap(find.byIcon(Icons.navigation));
      await tester.pumpAndSettle();

      expect(find.text('位置情報の権限が必要です'), findsOneWidget);
      expect(find.text('設定を開く'), findsOneWidget);
      expect(iconColor(tester, Icons.navigation), Colors.grey);
    },
  );

  testWidgets('point visibility button toggles markerVisibilityProvider', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    expect(iconColor(tester, Icons.location_on), isNot(Colors.grey));

    await tester.tap(find.byIcon(Icons.location_on));
    await tester.pumpAndSettle();

    expect(iconColor(tester, Icons.location_on), Colors.grey);
  });

  testWidgets('settings button navigates to the settings route', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('設定画面'), findsOneWidget);
  });
}
