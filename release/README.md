# リリース自動化

ローカルマシンから各街道アプリを App Store / Google Play に提出するためのスクリプト。

## リリース準備チェックリスト

初回リリース（4.0.0）までに必要なもの。完了したらチェックを入れる。

- [x] **Android keystore** — アップロード鍵 `.credentials/kaido.jks` 配置済み。
      全アプリの `android/key.properties` 設定済み（alias: `upload`）。
      署名付き AAB のビルドと証明書一致を確認済み（2026-07-14）。
      鍵とパスワードは Downloads に残さず安全な場所にバックアップすること
- [ ] **App Store Connect API キー** — App Store Connect → ユーザーとアクセス → 統合 →
      キーを生成（アクセス: App Manager）。`.p8` / Key ID / Issuer ID を取得して
      `./release/release.sh setup` で登録
- [ ] **Google Play サービスアカウント JSON** — Google Cloud でサービスアカウント作成 →
      Play Console の「API アクセス」でリンクしリリース権限を付与 → `setup` で登録
- [ ] **Apple Team ID → ExportOptions.plist** — Apple Developer の Membership ページで
      Team ID を確認し、`apps/*/ios/ExportOptions.plist` の
      `REPLACE_WITH_APPLE_TEAM_ID` を置換（tokaido 以外の4アプリはファイル自体が未作成）
- [ ] **env/production.json** — `env/production.json.template` を元に作成。
      API_BASE_URL / API_TOKEN / Google Maps API キー（iOS・Android）を記入
- [ ] **fastlane** — `gem install fastlane`（Android のアップロードに必要）
- [ ] **oshudo の App Store Connect アプリ登録** — iOS 版は旧アプリがストア未公開のため、
      `com.ground-base.oshudo` のアプリを新規作成する必要がある

すべて揃ったら `./release/release.sh build tokaido all` でビルド確認 →
`release` で TestFlight / 内部テストへ提出する。

## 前提条件

- macOS（Xcode インストール済み）
- Flutter SDK
- fastlane（Android 提出に必要）

```bash
gem install fastlane
```

## 初期セットアップ

初回のみ、Apple / Google の認証情報をセットアップする。

```bash
./release/release.sh setup
```

対話形式で以下を設定する:

| 認証情報 | 取得方法 |
|---------|---------|
| Apple API Key (.p8) | App Store Connect → ユーザーとアクセス → 統合 → App Store Connect API → キーを生成 |
| Apple Key ID / Issuer ID | 上記画面に表示される |
| Google Play Service Account JSON | Google Cloud Console → IAM → サービスアカウント → JSON キー作成 → Play Console で権限付与 |

認証情報は `.credentials/` に保存される（`.gitignore` 済み）。

セットアップ状態の確認:

```bash
./release/release.sh status
```

## 使い方

### ストアに提出する

```bash
# iOS のみ
./release/release.sh release tokaido ios

# Android のみ
./release/release.sh release nakasendo android

# 両方
./release/release.sh release oshudo all
```

実行すると以下が順に行われる:

1. バージョン確認・続行の確認プロンプト
2. `flutter build ipa` または `flutter build appbundle`
3. ストアへアップロード（iOS: App Store Connect / Android: Google Play 内部テストトラック）

### ビルドのみ（提出なし）

```bash
./release/release.sh build tokaido ios
./release/release.sh build nakasendo android
```

### バージョン更新

```bash
./release/release.sh version all 4.1.0       # 全アプリ一括（推奨）
./release/release.sh version tokaido 4.1.0   # 単一アプリのみ
```

`pubspec.yaml` の `version` を更新する。ビルド番号は全アプリで統一しており、
常に「全アプリ中の最大ビルド番号 +1」が自動採番される（Google Play の
versionCode 単調増加の要件を満たすため）。pubspec の version は直接編集せず、
必ずこのコマンドを使うこと。

## 対応アプリ

| 引数 | アプリ名 | iOS Bundle ID | Android applicationId |
|------|---------|-----------|-----------|
| `tokaido` | 東海道五十三次 | `com.ground-base.tokaido` | `com.groundbase.tokaido` |
| `nakasendo` | 中山道六十九次 | `com.ground-base.nakasendo` | `com.groundbase.nakasendo` |
| `koshudo` | 甲州道中四十四次 | `com.ground-base.koshudo` | `com.groundbase.koshudo` |
| `nikkodo` | 日光道中二十一次 | `com.ground-base.nikkodo` | `com.groundbase.nikkodo` |
| `oshudo` | 奥州道中十次 | `com.ground-base.oshudo` | `com.groundbase.oshudo` |

## ディレクトリ構成

```
release/
├── release.sh    # メインスクリプト
└── README.md     # 本ドキュメント

.credentials/     # 認証情報（.gitignore 済み）
├── kaido.jks     # Android アップロード鍵（全アプリ共通、alias: upload）
├── apple_api_key.p8
├── apple_api_config.env
└── google_play_service_account.json

apps/<app>/android/key.properties   # 署名設定（.gitignore 済み、パスワードを含む）
```

## 提出先

- **iOS**: App Store Connect → TestFlight に配信される。本番公開は App Store Connect から手動で行う。
- **Android**: Google Play Console の内部テストトラックに配信される。本番公開は Play Console から手動でトラックを昇格する。
