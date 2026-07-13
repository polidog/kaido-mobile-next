# kaido-mobile-next

江戸時代の五街道を地図上で辿れるモバイルアプリ群です。宿場・名所・一里塚・浮世絵スポットなどを Google Maps 上に表示し、GPS 追従やコンパスモードで実際に街道を歩きながら使えます。

## アプリ一覧

| パッケージ名 | 街道 |
|---|---|
| `apps/tokaido` | 東海道五十三次 |
| `apps/nakasendo` | 中山道六十九次 |
| `apps/koshudo` | 甲州道中四十四次 |
| `apps/nikkodo` | 日光道中二十一次 |
| `apps/oshudo` | 奥州道中十次 |

## プロジェクト構成

```
kaido-mobile-next/
├── apps/                  # 各街道アプリ（Flutter アプリ本体）
├── packages/
│   ├── kaido_api/         # API クライアント (Retrofit + Freezed)
│   ├── kaido_data/        # ドメインモデル・リポジトリ・Riverpod プロバイダ
│   └── kaido_ui/          # 共通 UI（テーマ・ルーター・地図画面・アプリシェル）
├── env/                   # 環境変数テンプレート
├── release/               # リリーススクリプト
└── docs/                  # ドキュメント
```

Dart ワークスペース + Melos によるモノレポ構成です。

## 技術スタック

- **Flutter** 3.44+ / Dart 3.12+
- **状態管理**: Riverpod (flutter_riverpod + riverpod_generator)
- **ルーティング**: go_router
- **API 通信**: Dio + Retrofit
- **コード生成**: Freezed, json_serializable, retrofit_generator
- **地図**: google_maps_flutter
- **Lint**: very_good_analysis

## セットアップ

### 前提条件

- Flutter SDK 3.44 以上
- Android Studio または Xcode
- Google Maps API キー

### 1. 依存パッケージのインストール

```bash
flutter pub get
```

### 2. 環境変数の設定

テンプレートをコピーして実ファイルを作成し、`REPLACE_ME` を実際の値に置き換えてください。

```bash
cp env/development.json.template env/development.json
cp env/production.json.template env/production.json
```

#### 環境変数一覧

| 変数名 | 用途 |
|---|---|
| `API_BASE_URL` | kaido-web-next API のベース URL |
| `API_TOKEN` | API 認証用 Bearer トークン |
| `GOOGLE_API_KEY_IOS` | iOS 用 Google Maps API キー |
| `GOOGLE_API_KEY_ANDROID` | Android 用 Google Maps API キー |
| `CONTACT_EMAIL` | 問い合わせ送信先メールアドレス |

> **注意**: `env/*.json` は `.gitignore` で除外されています。秘密情報を含むため絶対にコミットしないでください。

> Google Maps API キーは `env/*.json` から各プラットフォームに自動で渡ります。
> Android は Gradle が `GOOGLE_API_KEY_ANDROID` を `AndroidManifest.xml` に注入し、
> iOS は起動時に `GOOGLE_API_KEY_IOS` を MethodChannel 経由で Maps SDK に渡します。

### 3. Android 固有の設定

各アプリの `android/` ディレクトリにあるテンプレートをコピーして設定します。

```bash
# 署名設定（リリースビルド用）
cp apps/tokaido/android/key.properties.template apps/tokaido/android/key.properties
```

`key.properties`:

| キー | 用途 |
|---|---|
| `storePassword` | キーストアのパスワード |
| `keyPassword` | キーのパスワード |
| `keyAlias` | キーエイリアス（デフォルト: `upload`） |
| `storeFile` | キーストアファイルのパス |

### 4. コード生成

Freezed・Retrofit・Riverpod のコード生成を実行します。

```bash
dart run melos run build:gen
```

## 開発

### アプリの実行

```bash
# 開発環境で東海道アプリを実行
cd apps/tokaido
flutter run --dart-define-from-file=../../env/development.json
```

### Melos スクリプト

```bash
dart run melos run analyze    # 全パッケージで dart analyze を実行
dart run melos run test        # 全パッケージでテストを実行
dart run melos run build:gen   # コード生成（freezed, riverpod, retrofit）
dart run melos run clean       # 全パッケージをクリーン
```

## ビルド

```bash
# Android APK（本番）
cd apps/tokaido
flutter build apk --dart-define-from-file=../../env/production.json

# iOS（本番）
cd apps/tokaido
flutter build ios --dart-define-from-file=../../env/production.json
```
