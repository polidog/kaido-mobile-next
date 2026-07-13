---
name: simulator
description: Android エミュレータ / iOS シミュレータの起動・停止・状態確認と、各街道アプリ（tokaido / nakasendo / koshudo / nikkodo / oshudo）のシミュレータ上での実行を行う。ユーザーが「エミュレータで動かして」「シミュレータ起動して」「iOS/Androidで実行して」「アプリを立ち上げて」「シミュレータ落として」など、シミュレータ・エミュレータ・実機以外でのアプリ実行に関することを言ったら必ずこのスキルを使う。flutter run の起動方法やデバイス指定に迷ったときもまずこれを読む。
---

# シミュレータ操作

このプロジェクトは Flutter モノレポで、`apps/` 配下に5つの街道アプリがある。
シミュレータの起動・停止は `scripts/simulator.sh` に集約されている。直接
`emulator` や `simctl` を叩かず、まずこのスクリプトを使う。

## シミュレータの起動・停止・状態確認

```bash
scripts/simulator.sh                  # Android + iOS 両方起動（起動済みならスキップ）
scripts/simulator.sh start android    # Android エミュレータのみ起動
scripts/simulator.sh start ios        # iOS シミュレータのみ起動
scripts/simulator.sh stop [android|ios|all]   # 停止
scripts/simulator.sh status           # 起動状態を表示
```

**状態確認だけしたいときは必ず `status` を使う** — 引数なしで実行すると
「両方起動」の意味になり、起動が走ってしまう。

`status` の出力例（常に exit 0。起動判定は出力から読み取る）:

```
[simulator] Android エミュレータ:
emulator-5554	device          ← "device" なら起動済み（"offline" は起動未完了）
[simulator] iOS シミュレータ:
    iPhone 17 Pro (2047...-...) (Booted)   ← Booted 行がなければ "(なし)" と表示
```

- ブート完了まで待機してから終了するので、終了後すぐ `flutter run` してよい
- デバイスは環境変数で切り替え可能: `AVD_NAME=xxx` / `IOS_DEVICE="iPhone 17 Pro"`
- **停止はユーザーのアプリ実行セッションも道連れにする**。`flutter run` が動いて
  いそうな場合（バックグラウンドタスクや別ターミナル）は停止前にユーザーへ確認する

## アプリをシミュレータで実行する

必ず対象アプリのディレクトリから、env ファイル指定つきで実行する。
env 指定を忘れると API キーが渡らず地図もAPIも動かない。

```bash
cd apps/tokaido   # 対象アプリに応じて変更
flutter run -d <デバイスID> --dart-define-from-file=../../env/development.json
```

デバイスIDの調べ方:

```bash
flutter devices   # Android は emulator-5554 のような serial、iOS は UDID
```

`flutter run` は対話型で終了しないため、**Bash の run_in_background で起動**し、
出力ファイルを `Flutter run key commands`（成功）や `Error|BUILD FAILED`（失敗）
で監視する。ホットリロードは出力ファイル経由では送れないので、リロードが必要な
ら再起動する。

## 環境の前提

- `env/development.json` が存在すること（なければ `env/development.json.template`
  をコピーして値を埋めるようユーザーに案内する）
- iOS ランタイム・CocoaPods・Xcode ライセンスはセットアップ済みの想定。壊れて
  いる場合は下のトラブルシューティングを見る

## トラブルシューティング（この環境で実際に起きたもの）

| 症状 | 原因と対処 |
|---|---|
| `flutter` が exit 69 で即失敗、"Xcode license" 警告 | Xcode ライセンス未同意。ユーザーに `sudo xcodebuild -license accept` を実行してもらう（sudo が必要なので代行不可） |
| `simctl` が "CoreSimulator... No such file" | Xcode 初回セットアップ未完了。ユーザーに `sudo xcodebuild -runFirstLaunch` を実行してもらう |
| `simctl list runtimes` が空 | iOS ランタイム未ダウンロード。`xcodebuild -downloadPlatform iOS`（約8.5GB、バックグラウンド実行推奨） |
| `Runner.xcodeproj ... damaged / parse error` | `project.pbxproj` の構文エラー。`plutil -lint` で検証し、直近の手編集コミットを疑う |
| `pod install` が deployment target エラー | プラグインの最低 iOS バージョン上げ要求。`Podfile` の `platform :ios` と pbxproj の `IPHONEOS_DEPLOYMENT_TARGET` を揃えて上げる（現在 14.0） |
| Android で地図が出ず `GoogleCertificatesRslt: not allowed` | Google Maps API キーのアプリ制限にデバッグ署名の SHA-256 が未登録。ログの sha256 を Google Cloud Console に登録するようユーザーに案内 |
| API が `Failed host lookup` | `env/development.json` の `API_BASE_URL` が未設定/ダミー。Android エミュレータからホストへは `http://10.0.2.2:<port>`、iOS シミュレータは `http://localhost:<port>` |
