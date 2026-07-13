import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/pages/gokaido_page.dart';

import '../helpers/fake_assets.dart';

const _testConfig = KaidoConfig(
  appName: 'テストアプリ',
  apiContext: 'tokaido',
  themeColor: Color(0xFFECB404),
  assetPrefix: 'assets',
);

Widget _buildGokaidoPage({AssetLoader? assetLoader}) {
  return ProviderScope(
    overrides: [
      kaidoConfigProvider.overrideWithValue(_testConfig),
      assetLoaderProvider.overrideWithValue(assetLoader ?? FakeAssetLoader()),
    ],
    child: const MaterialApp(home: GokaidoPage()),
  );
}

void main() {
  testWidgets('GokaidoPage renders introduction and route cards', (
    tester,
  ) async {
    await tester.pumpWidget(_buildGokaidoPage());
    await tester.pumpAndSettle();

    expect(find.text('五街道案内'), findsOneWidget);
    expect(find.text('五街道について'), findsOneWidget);
    expect(find.text('テスト用の五街道紹介です。'), findsOneWidget);
    expect(find.text('東海道五十三次'), findsOneWidget);
    expect(find.text('テスト用の街道説明です。'), findsOneWidget);
    expect(find.text('歴史メモ'), findsOneWidget);
    expect(find.text('テスト用の歴史メモです。'), findsOneWidget);
    // テスト実行環境（デスクトップ）では両ストアのボタンが表示される。
    expect(find.text('Google Play'), findsOneWidget);
    expect(find.text('App Store'), findsOneWidget);
  });

  testWidgets('GokaidoPage shows an error message on load failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildGokaidoPage(
        assetLoader: FakeAssetLoader(assets: {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('エラーが発生しました'), findsOneWidget);
  });
}
