import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/kaido_data.dart';

class _FakePoints extends Points {
  @override
  Future<List<Point>> build() async => const [];
}

class _FailingPoints extends Points {
  @override
  Future<List<Point>> build() async => throw Exception('points failed');
}

class _FakeRoutes extends Routes {
  @override
  Future<List<RoutePoint>> build() async => const [];
}

class _FakeDetours extends Detours {
  @override
  Future<List<Detour>> build() async => const [];
}

void main() {
  group('DataUpdate', () {
    test('completes when all providers refresh successfully', () async {
      final container = ProviderContainer(
        overrides: [
          pointsProvider.overrideWith(_FakePoints.new),
          routesProvider.overrideWith(_FakeRoutes.new),
          detoursProvider.overrideWith(_FakeDetours.new),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(dataUpdateProvider.future),
        completes,
      );
    });

    test('fails when one of the providers fails to refresh', () async {
      final container = ProviderContainer(
        overrides: [
          pointsProvider.overrideWith(_FailingPoints.new),
          routesProvider.overrideWith(_FakeRoutes.new),
          detoursProvider.overrideWith(_FakeDetours.new),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(dataUpdateProvider.future),
        throwsA(anything),
      );
    });
  });
}
