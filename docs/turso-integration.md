# Turso embedded replica 統合

モバイルアプリのデータ取得を REST API（spots/routes/detours）から
**Turso embedded replica**（アプリ内にレプリカ DB を同期しローカル読取）に
移行した際の設計メモ。kaido-web-next 側との連携仕様もここに記す。

## アーキテクチャ

```
起動時:
  アプリ → GET /api/v1/maps (X-API-Key 認証)
        → aliasName が一致するマップの databaseUrl を取得
        → SharedPreferences にキャッシュ（次回以降のオフライン起動用）
  アプリ → libsql_dart で embedded replica を open + sync
        → Application Support/turso/<context>.db にレプリカ生成
  以降の読取はすべてローカル DB（オフライン動作可）

データフロー（既存アーキテクチャは維持）:
  Riverpod Provider → Repository（キャッシュ→リモート→バンドルの既存フロー）
                    → TursoXxxDataSource（旧 REST データソースと同一インターフェース）
                    → TursoMapDatabase（レプリカ管理・SQL 実行）
```

- 実装: `packages/kaido_data/lib/datasources/turso/`
- 読み取るテーブル: `spots` / `route_groups` + `route_points` /
  `detours` + `detour_routes`（kaido-web-next の docs/database-schema.md 準拠）
- `category_id`(1-5) はアプリ側で表示名（宿場・一里塚・名所・浮世絵ポイント・見付）に変換
- ルート・迂回路は DB の `color`（HEX）で描画し、無ければアプリ既定色

## 認証トークンの扱い

### 現状（暫定運用）

- `turso group tokens create kaido --read-only` で発行した
  **読み取り専用グループトークン**を `env/*.json` の `TURSO_AUTH_TOKEN` として
  ビルド時に埋め込む（`--dart-define-from-file`）
- kaido-web-next の `/api/v1/maps/[mapId]/config` は「authToken は別の認証フローで
  取得する設計」とコメントされているが、そのフローは未実装のため上記で代替

### バックエンドへの提案（トークン取得 API の契約案）

アプリ埋め込みトークンを廃止する場合、kaido-web-next に以下を実装してほしい:

```
GET /api/v1/maps/{mapId}/token
  認証: X-API-Key（既存の API キー認証と同じ）
  レスポンス: {
    "authToken": "<読み取り専用 JWT>",
    "expiresAt": "2026-08-01T00:00:00Z"
  }
```

- Turso Platform API でマップ DB スコープ・read-only・有効期限付きのトークンを
  動的発行して返す
- モバイル側は起動時に取得し、期限切れ前に再取得してレプリカの sync に使う
- これが入るまでモバイルは `TURSO_AUTH_TOKEN`（dart-define）を優先使用する

### トークンのローテーション

漏洩時は `turso group tokens invalidate kaido` で全トークンを無効化し、
再発行したトークンでアプリを再ビルド・再リリースする（グループ単位で一括失効
なので、Web 側が同じグループのトークンを使っている場合は影響に注意）。

## 制約・注意点

- **libsql_dart のビルドには Rust ツールチェーンが必要**
  （`brew install rustup && rustup default stable`）。CI にも同様のセットアップが要る
- libsql_dart はコミュニティパッケージ（v0.9.0）。Turso 公式ドキュメントが
  参照しているが採用実績は少なめなので、アップデート時は動作確認を丁寧に
- 初回起動はレプリカ同期のためネットワーク必須。同期失敗時は
  旧アプリから引き継いだバンドル JSON（assets/json/*.json）にフォールバックする
  （迂回路のみバンドルが空なので初回オフライン時は表示されない）
- REST の `/api/v1/maps/{context}/spots|routes|detours` エンドポイントは
  もはや不要（kaido_api の該当クライアントコードは互換のため残置）

## スキーマ文書と実 DB の差異（2026-07-18 判明）

kaido-web-next の docs/database-schema.md には `detours.color` が定義されて
いるが、**実際の各マップ DB の detours テーブルに color カラムは存在しない**
（route_groups には存在する）。モバイル側は detours を `SELECT *` で読み、
color は存在すれば使う実装にして両対応済み。バックエンド側でカラムを追加
するか、スキーマ文書を実体に合わせて修正してほしい。
