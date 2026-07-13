import 'package:kaido_data/kaido_data.dart';

/// テスト用の `assets/data/introduction.json` 相当のデータ。
const fakeIntroductionJson = '''
{
  "intro": {
    "title": "はじめに",
    "content": "テスト用の紹介文です。",
    "updateNote": "テスト用の更新メモです。"
  },
  "supplementaryInfo": [
    {
      "title": "ルート",
      "content": "テスト用のルート補足です。",
      "icon": "route"
    }
  ],
  "terminology": [
    {
      "title": "宿場",
      "content": "テスト用の宿場説明です。",
      "icon": "location_city"
    }
  ]
}
''';

/// テスト用の `assets/data/help_texts.json` 相当のデータ。
const fakeHelpTextsJson = '''
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
          {
            "type": "point",
            "title": "ポイントアイコン",
            "description": "タップすると説明画面が表示されます。"
          }
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
    "info": {
      "title": "テスト用のデータ更新案内です。",
      "description": "テスト用のデータ更新説明です。"
    },
    "warning": "テスト用の警告です。"
  },
  "inquiry": {
    "title": "お問い合わせ",
    "main_text": "テスト用のお問い合わせ案内です。",
    "help_text": "テスト用のお問い合わせ補足です。",
    "required_info": ["お使いの端末の機種名"],
    "screenshot_note": {
      "icon": "photo_camera",
      "text": "テスト用のスクリーンショット案内です。"
    }
  },
  "tips": {
    "title": "上手に使うコツ",
    "items": [
      {
        "icon": "battery_saver",
        "title": "バッテリーの節約",
        "description": "テスト用のコツです。"
      }
    ]
  }
}
''';

/// テスト用の `assets/data/gokaido_data.json` 相当のデータ。
const fakeGokaidoJson = '''
{
  "introduction": {
    "title": "五街道について",
    "content": "テスト用の五街道紹介です。",
    "note": "テスト用の注記です。"
  },
  "routes": [
    {
      "title": "東海道五十三次",
      "content": "テスト用の街道説明です。",
      "historicalNote": "テスト用の歴史メモです。",
      "icon": "directions_walk",
      "appLinks": {
        "android": "https://example.com/android",
        "ios": "https://example.com/ios"
      }
    }
  ]
}
''';

/// アセットキーに応じた JSON を返すテスト用 [AssetLoader]。
class FakeAssetLoader implements AssetLoader {
  /// Creates a [FakeAssetLoader].
  FakeAssetLoader({Map<String, String>? assets})
      : _assets = assets ??
            {
              'assets/data/introduction.json': fakeIntroductionJson,
              'assets/data/help_texts.json': fakeHelpTextsJson,
              'assets/data/gokaido_data.json': fakeGokaidoJson,
            };

  final Map<String, String> _assets;

  @override
  Future<String> loadString(String key) async {
    final value = _assets[key];
    if (value == null) {
      throw ArgumentError('No fake asset registered for key: $key');
    }
    return value;
  }
}
