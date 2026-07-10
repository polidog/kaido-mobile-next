# リリース自動化

ローカルマシンから各街道アプリを App Store / Google Play に提出するためのスクリプト。

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
./release/release.sh release oshu all
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
./release/release.sh version tokaido 3.2.0
```

`pubspec.yaml` の `version` を更新し、ビルド番号を自動インクリメントする。

## 対応アプリ

| 引数 | アプリ名 | Bundle ID |
|------|---------|-----------|
| `tokaido` | 東海道五十三次 | `com.kaido.tokaido` |
| `nakasendo` | 中山道六十九次 | `com.kaido.nakasendo` |
| `koshu` | 甲州道中 | `com.kaido.koshu` |
| `nikko` | 日光道中 | `com.kaido.nikko` |
| `oshu` | 奥州道中 | `com.kaido.oshu` |

## ディレクトリ構成

```
release/
├── release.sh    # メインスクリプト
└── README.md     # 本ドキュメント

.credentials/     # 認証情報（.gitignore 済み）
├── apple_api_key.p8
├── apple_api_config.env
└── google_play_service_account.json
```

## 提出先

- **iOS**: App Store Connect → TestFlight に配信される。本番公開は App Store Connect から手動で行う。
- **Android**: Google Play Console の内部テストトラックに配信される。本番公開は Play Console から手動でトラックを昇格する。
