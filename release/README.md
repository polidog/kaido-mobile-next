# リリース自動化

ローカルマシンから各街道アプリを App Store / Google Play に提出するためのスクリプト。

## リリース準備チェックリスト

初回リリース（4.0.0）までに必要なもの。完了したらチェックを入れる。

- [x] **Android keystore** — アップロード鍵 `.credentials/kaido.jks` 配置済み。
      全アプリの `android/key.properties` 設定済み（alias: `upload`）。
      署名付き AAB のビルドと証明書一致を確認済み（2026-07-14）。
      鍵とパスワードは Downloads に残さず安全な場所にバックアップすること
- [x] **App Store Connect API キー** — 登録済み（Key ID: RX6B848JH3）。
      `.credentials/` に加え、altool が参照する `~/.appstoreconnect/private_keys/` にも
      `.p8` を配置済み。API 疎通確認済み（2026-07-17）
- [x] **Google Play サービスアカウント JSON** — サービスアカウント
      `kaido-release@gokaido-1086.iam.gserviceaccount.com` 作成・JSON 登録済み。
      Play Console「ユーザーと権限」での招待も完了し、全5パッケージで
      Play Developer API の疎通確認済み（2026-07-17）
- [x] **Apple Team ID → ExportOptions.plist** — Team ID は `6TGS8GNR43`。
      ⚠️ bundleIds API の seedId（HWA4V543C6）は App ID プレフィックスであり
      Team ID ではないので注意。全5アプリの plist を manual 署名 +
      プロファイル指定（`kaido-<app>-appstore`）で作成済み。
      `destination` は release.sh の設計（altool で別途アップロード）に合わせ `export`
- [x] **iOS 署名体制（Xcode ログイン不要のヘッドレス構成）** — 2026-07-18 構築。
      Apple Distribution 証明書（ID: N9Y792J8Y5、期限 2027-07-17）を
      fastlane + ASC API キーで作成し、ログインキーチェーンに導入済み
      （p12 バックアップ: `.credentials/certs/`）。App Store プロファイル
      `kaido-<app>-appstore` × 5 を作成済み（`.credentials/profiles/`）。
      pbxproj の Release/Profile 構成は manual 署名。
      別マシンで構築し直す場合は p12 をインポート後に
      `security set-key-partition-list -S apple-tool:,apple:,codesign: -s
      ~/Library/Keychains/login.keychain-db` の実行が必要（errSecInternalComponent 対策）
- [x] **ビルド検証** — tokaido で iOS（IPA 36MB）/ Android（AAB 60MB）とも
      成功を確認（2026-07-18）。⚠️ Launch image が Flutter デフォルトのままなので
      ストア公開までに差し替え推奨
- [x] **env/production.json** — 作成済み（2026-07-17）。API_BASE_URL は
      `https://kaido-web-next.vercel.app`、Maps キーは gokaido-1086 の既存キー
      （iOS: 「iOSアプリ用」/ Android: 「2023Android本番用」）を使用。
      ⚠️ ただしアプリが使う `/api/v1/maps/{context}/spots|routes|detours` は
      バックエンド未実装（404）。kaido-web-next 側の実装・デプロイ完了が
      リリースの前提条件（別セッションで対応中）
- [x] **fastlane** — インストール済み（brew, 2.237.0）
- [x] **oshudo の App Store Connect アプリ登録** — 登録済みを確認（2026-07-17、
      ASC API のアプリ一覧に `com.ground-base.oshudo` が存在）

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

⚠️ この採番はローカルの pubspec しか見ないため、**旧アプリが Play 上で
使用済みの versionCode との衝突は検知できない**。旧アプリの使用済み最大値は
26（tokaido、2026-07-18 調査）で、現行の 4.0.0+27 はそれを踏まえた採番。
「Version code N has already been used」エラーが出たら、Play Developer API の
edits/bundles 一覧で全パッケージの使用済み versionCode を確認して
それより大きい番号に更新すること。

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
