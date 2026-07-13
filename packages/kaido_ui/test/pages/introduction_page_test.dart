import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/pages/introduction_page.dart';

import '../helpers/fake_assets.dart';

const _testConfig = KaidoConfig(
  appName: 'テストアプリ',
  apiContext: 'tokaido',
  themeColor: Color(0xFFECB404),
  assetPrefix: 'assets',
);

Widget _buildIntroductionPage({AssetLoader? assetLoader}) {
  return ProviderScope(
    overrides: [
      kaidoConfigProvider.overrideWithValue(_testConfig),
      assetLoaderProvider.overrideWithValue(assetLoader ?? FakeAssetLoader()),
    ],
    child: const MaterialApp(home: IntroductionPage()),
  );
}

void main() {
  testWidgets('IntroductionPage renders sections from the JSON asset', (
    tester,
  ) async {
    await tester.pumpWidget(_buildIntroductionPage());
    await tester.pumpAndSettle();

    expect(find.text('はじめに'), findsNWidgets(2)); // AppBar + カードタイトル
    expect(find.text('テスト用の紹介文です。'), findsOneWidget);
    expect(find.text('テスト用の更新メモです。'), findsOneWidget);
    expect(find.text('表示に関しての補足'), findsOneWidget);
    expect(find.text('ルート'), findsOneWidget);
    expect(find.text('用語'), findsOneWidget);
    expect(find.text('宿場'), findsOneWidget);
  });

  testWidgets('IntroductionPage shows an error message on load failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildIntroductionPage(
        assetLoader: FakeAssetLoader(assets: {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('エラーが発生しました'), findsOneWidget);
  });
}
