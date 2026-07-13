import 'dart:async';

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

class _FakeRoutes extends Routes {
  @override
  Future<List<RoutePoint>> build() async => const [];
}

class _FakeDetours extends Detours {
  @override
  Future<List<Detour>> build() async => const [];
}

/// Never-resolving fakes to simulate data that keeps loading.
class _NeverPoints extends Points {
  @override
  Future<List<Point>> build() => Completer<List<Point>>().future;
}

class _NeverRoutes extends Routes {
  @override
  Future<List<RoutePoint>> build() => Completer<List<RoutePoint>>().future;
}

class _NeverDetours extends Detours {
  @override
  Future<List<Detour>> build() => Completer<List<Detour>>().future;
}

void main() {
  Future<void> pumpSplash(
    WidgetTester tester, {
    required Points Function() points,
    required Routes Function() routes,
    required Detours Function() detours,
  }) async {
    final router = createKaidoRouter(initialLocation: '/splash');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          kaidoConfigProvider.overrideWithValue(_testConfig),
          pointsProvider.overrideWith(points),
          routesProvider.overrideWith(routes),
          detoursProvider.overrideWith(detours),
          initialCameraPositionProvider.overrideWith((ref) async => null),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'SplashPage navigates to MapPage once data is ready and the minimum '
    'display time has elapsed',
    (tester) async {
      await pumpSplash(
        tester,
        points: _FakePoints.new,
        routes: _FakeRoutes.new,
        detours: _FakeDetours.new,
      );

      expect(find.byType(MapPage), findsNothing);

      // データは即座に揃うが、最低表示時間（2秒）までは留まる。
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(MapPage), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byType(MapPage), findsOneWidget);
    },
  );

  testWidgets(
    'SplashPage navigates after the maximum wait even if data never resolves',
    (tester) async {
      await pumpSplash(
        tester,
        points: _NeverPoints.new,
        routes: _NeverRoutes.new,
        detours: _NeverDetours.new,
      );

      // 最低表示時間を過ぎてもデータが揃わない間は留まる。
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.byType(MapPage), findsNothing);

      // 上限（5秒）に達したら諦めて遷移する。
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      await tester.pump();

      expect(find.byType(MapPage), findsOneWidget);
    },
  );
}
