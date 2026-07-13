import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/pages/help_page.dart';

import '../helpers/fake_assets.dart';

const _testConfig = KaidoConfig(
  appName: 'テストアプリ',
  apiContext: 'tokaido',
  themeColor: Color(0xFFECB404),
  assetPrefix: 'assets',
);

Widget _buildHelpPage({AssetLoader? assetLoader}) {
  return ProviderScope(
    overrides: [
      kaidoConfigProvider.overrideWithValue(_testConfig),
      assetLoaderProvider.overrideWithValue(assetLoader ?? FakeAssetLoader()),
    ],
    child: const MaterialApp(home: HelpPage()),
  );
}

void main() {
  testWidgets('HelpPage renders sections from the JSON asset', (
    tester,
  ) async {
    await tester.pumpWidget(_buildHelpPage());
    await tester.pumpAndSettle();

    expect(find.text('ヘルプ'), findsOneWidget);
    expect(find.text('メイン画面'), findsOneWidget);
    expect(find.text('ルート表示'), findsOneWidget);
    expect(find.text('旧道'), findsOneWidget);
    expect(find.text('マップアイコン'), findsOneWidget);
    expect(find.text('宿場（本陣）'), findsOneWidget);

    // 画面下部のセクションまで順にスクロールして確認する。
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('操作方法'),
      200,
      scrollable: scrollable,
    );
    expect(find.text('操作方法'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('GPSのON/OFF'),
      200,
      scrollable: scrollable,
    );
    expect(find.text('下部ツールバー'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('テスト用の警告です。'),
      200,
      scrollable: scrollable,
    );
    expect(find.text('データアップデート'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('お問い合わせ'),
      200,
      scrollable: scrollable,
    );
    expect(find.text('お問い合わせ'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('バッテリーの節約'),
      200,
      scrollable: scrollable,
    );
    expect(find.text('上手に使うコツ'), findsOneWidget);
    expect(find.text('バッテリーの節約'), findsOneWidget);
  });

  testWidgets('HelpPage shows an error message on load failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHelpPage(
        assetLoader: FakeAssetLoader(assets: {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('ヘルプテキストの読み込みに失敗しました'),
      findsOneWidget,
    );
  });
}
