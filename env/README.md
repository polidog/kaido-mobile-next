# env/

このディレクトリは、Flutter の `--dart-define-from-file` オプションで各アプリに注入する
環境変数ファイルを配置する場所です。旧構成の `.env` + `flutter_dotenv` は廃止し、
ビルド時に JSON ファイルとして環境変数を渡す方式に統一しています。

## 使い方

1. 環境に応じたテンプレートファイルをコピーして実ファイルを作成します。

   ```bash
   cp env/development.json.template env/development.json
   cp env/production.json.template env/production.json
   ```

2. コピーした `env/*.json` の `REPLACE_ME` 部分を実際の値（API トークンや
   Google Maps API キーなど）に書き換えます。

3. ビルド・実行時に `--dart-define-from-file` で読み込みます。

   ```bash
   flutter run --dart-define-from-file=env/development.json
   flutter build apk --dart-define-from-file=env/production.json
   ```

## 変数一覧

| 変数名 | 用途 |
| --- | --- |
| `API_BASE_URL` | kaido-web-next API のベース URL |
| `API_TOKEN` | API 認証用 Bearer トークン |
| `GOOGLE_API_KEY_IOS` | iOS 用 Google Maps API キー |
| `GOOGLE_API_KEY_ANDROID` | Android 用 Google Maps API キー |
| `CONTACT_EMAIL` | 問い合わせ送信先メールアドレス |
| `FEATURE_3D_HEADING` | (任意) `true` で実験的な3Dヘディングモードを有効化。GPSフォロー中に地図上へ切替ボタンが表示される。未設定時は無効 |

## Google Maps API キーの流れ

- **Android**: Flutter ツールが dart-define を Gradle プロパティ（base64）として渡すため、
  各アプリの `android/app/build.gradle.kts` がデコードして `GOOGLE_API_KEY_ANDROID` を
  `AndroidManifest.xml` の `com.google.android.geo.API_KEY` に注入します。
- **iOS**: dart-define は Xcode ビルドからは参照できないため、アプリ起動時に Dart 側
  （`kaido_ui` の `configureGoogleMapsApiKey`）が `GOOGLE_API_KEY_IOS` を MethodChannel で
  `AppDelegate` に渡し、`GMSServices.provideAPIKey` を呼び出します。

## 注意事項

- `env/*.json`（実ファイル）は `.gitignore` で除外されています。**秘密情報を含むため
  絶対にコミットしないでください。**
- `env/*.json.template` はプレースホルダのみを含むため、リポジトリで追跡します。
- CI/CD では GitHub Secrets から値を取得し、ビルド実行時に `env/production.json` を
  動的に生成する方針とします（リポジトリには含めません）。
