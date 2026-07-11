import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/pages/settings_page.dart';

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
  testWidgets('SettingsPage shows all settings entries', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          kaidoConfigProvider.overrideWithValue(_testConfig),
          pointsProvider.overrideWith(_FakePoints.new),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('はじめに'), findsOneWidget);
    expect(find.text('ヘルプ'), findsOneWidget);
    expect(find.text('五街道紹介'), findsOneWidget);
    expect(find.text('データ更新'), findsOneWidget);
    expect(find.text('著作権'), findsOneWidget);
  });
}
