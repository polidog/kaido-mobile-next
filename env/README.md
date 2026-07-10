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
| `GOOGLE_MAPS_API_KEY` | Google Maps API キー |
| `CONTACT_EMAIL` | 問い合わせ送信先メールアドレス |

## 注意事項

- `env/*.json`（実ファイル）は `.gitignore` で除外されています。**秘密情報を含むため
  絶対にコミットしないでください。**
- `env/*.json.template` はプレースホルダのみを含むため、リポジトリで追跡します。
- CI/CD では GitHub Secrets から値を取得し、ビルド実行時に `env/production.json` を
  動的に生成する方針とします（リポジトリには含めません）。
