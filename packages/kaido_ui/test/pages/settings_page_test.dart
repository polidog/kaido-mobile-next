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

Widget _buildSettingsPage() {
  return ProviderScope(
    overrides: [
      kaidoConfigProvider.overrideWithValue(_testConfig),
      pointsProvider.overrideWith(_FakePoints.new),
    ],
    child: const MaterialApp(home: SettingsPage()),
  );
}

void main() {
  testWidgets('SettingsPage shows all settings entries', (tester) async {
    await tester.pumpWidget(_buildSettingsPage());
    await tester.pumpAndSettle();

    expect(find.text('はじめに'), findsOneWidget);
    expect(find.text('ヘルプ'), findsOneWidget);
    expect(find.text('お問い合わせ'), findsOneWidget);
    expect(find.text('五街道'), findsOneWidget);
    expect(find.text('データアップデート'), findsOneWidget);
    expect(find.text('著作権情報'), findsOneWidget);
  });

  testWidgets('データアップデート tap shows a confirmation dialog', (tester) async {
    await tester.pumpWidget(_buildSettingsPage());
    await tester.pumpAndSettle();

    await tester.tap(find.text('データアップデート'));
    await tester.pumpAndSettle();

    expect(find.text('データを更新しますか？'), findsOneWidget);
    expect(find.text('通信状況の良い場所で更新を行ってください。'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
    expect(find.text('更新する'), findsOneWidget);
  });

  testWidgets('キャンセル closes the dialog without navigating', (tester) async {
    await tester.pumpWidget(_buildSettingsPage());
    await tester.pumpAndSettle();

    await tester.tap(find.text('データアップデート'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    expect(find.text('データを更新しますか？'), findsNothing);
    expect(find.text('設定'), findsOneWidget);
  });
}
