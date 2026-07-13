import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/kaido_data.dart';

import '../helpers/fake_asset_loader.dart';

const _testConfig = KaidoConfig(
  appName: 'テストアプリ',
  apiContext: 'tokaido',
  themeColor: Color(0xFFECB404),
  assetPrefix: 'assets',
);

const _introductionJson = '''
{
  "intro": {
    "title": "はじめに",
    "content": "テスト用の紹介文です。",
    "updateNote": "テスト用の更新メモです。"
  },
  "supplementaryInfo": [
    {"title": "ルート", "content": "補足です。", "icon": "route"}
  ],
  "terminology": [
    {"title": "宿場", "content": "用語です。", "icon": "location_city"}
  ]
}
''';

const _helpTextsJson = '''
{
  "main_screen": {
    "title": "メイン画面",
    "sections": {
      "route_display": {
        "title": "ルート表示",
        "items": [
          {"type": "old_road", "color": "#CD8080", "title": "旧道"}
        ]
      },
      "map_icons": {
        "title": "マップアイコン",
        "items": [
          {"type": "honjin", "icon": "marker_red.png", "title": "宿場（本陣）"}
        ]
      },
      "operations": {
        "title": "操作方法",
        "items": [
          {"type": "point", "title": "ポイントアイコン", "description": "説明"}
        ]
      }
    }
  },
  "toolbar": {
    "title": "下部ツールバー",
    "items": [
      {"icon": "navigation", "description": "GPSのON/OFF"}
    ]
  },
  "data_update": {
    "title": "データアップデート",
    "info": {"title": "案内", "description": "説明"},
    "warning": "警告"
  },
  "inquiry": {
    "title": "お問い合わせ",
    "main_text": "本文",
    "help_text": "補足",
    "required_info": ["機種名"],
    "screenshot_note": {"icon": "photo_camera", "text": "画像案内"}
  },
  "tips": {
    "title": "上手に使うコツ",
    "items": [
      {"icon": "battery_saver", "title": "バッテリーの節約", "description": "説明"}
    ]
  }
}
''';

const _gokaidoJson = '''
{
  "introduction": {
    "title": "五街道について",
    "content": "紹介です。",
    "note": "注記です。"
  },
  "routes": [
    {
      "title": "東海道五十三次",
      "content": "説明です。",
      "historicalNote": "歴史メモです。",
      "icon": "directions_walk",
      "appLinks": {"android": "https://example.com/a"}
    }
  ]
}
''';

ProviderContainer _createContainer() {
  final container = ProviderContainer(
    overrides: [
      kaidoConfigProvider.overrideWithValue(_testConfig),
      assetLoaderProvider.overrideWithValue(
        FakeAssetLoader({
          'assets/data/introduction.json': _introductionJson,
          'assets/data/help_texts.json': _helpTextsJson,
          'assets/data/gokaido_data.json': _gokaidoJson,
        }),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('introductionProvider', () {
    test('loads IntroductionData from the bundled JSON asset', () async {
      final container = _createContainer();

      final data = await container.read(introductionProvider.future);

      expect(data.intro.title, 'はじめに');
      expect(data.intro.updateNote, 'テスト用の更新メモです。');
      expect(data.supplementaryInfo, hasLength(1));
      expect(data.supplementaryInfo.first.icon, 'route');
      expect(data.terminology.first.title, '宿場');
    });
  });

  group('helpTextsProvider', () {
    test('loads HelpTexts from the bundled JSON asset', () async {
      final container = _createContainer();

      final data = await container.read(helpTextsProvider.future);

      expect(data.mainScreen.title, 'メイン画面');
      expect(
        data.mainScreen.sections.routeDisplay.items.first.color,
        '#CD8080',
      );
      expect(
        data.mainScreen.sections.mapIcons.items.first.icon,
        'marker_red.png',
      );
      expect(
        data.mainScreen.sections.operations.items.first.title,
        'ポイントアイコン',
      );
      expect(data.toolbar.items.first.icon, 'navigation');
      expect(data.dataUpdate.warning, '警告');
      expect(data.inquiry.mainText, '本文');
      expect(data.inquiry.requiredInfo, ['機種名']);
      expect(data.inquiry.screenshotNote.text, '画像案内');
      expect(data.tips.items.first.title, 'バッテリーの節約');
    });
  });

  group('gokaidoProvider', () {
    test('loads GokaidoData from the bundled JSON asset', () async {
      final container = _createContainer();

      final data = await container.read(gokaidoProvider.future);

      expect(data.introduction.title, '五街道について');
      expect(data.routes, hasLength(1));
      expect(data.routes.first.title, '東海道五十三次');
      expect(data.routes.first.icon, 'directions_walk');
      expect(data.routes.first.appLinks, {'android': 'https://example.com/a'});
    });
  });
}
