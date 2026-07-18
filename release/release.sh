#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CREDENTIALS_DIR="$ROOT_DIR/.credentials"

# ── 対応アプリ一覧 ─────────────────────────────────────
# macOS 標準の bash 3.2 には連想配列がないため case 関数で定義する
ALL_APPS=(tokaido nakasendo koshudo nikkodo oshudo)

bundle_ios() {
  case "$1" in
    tokaido)   echo "com.ground-base.tokaido" ;;
    nakasendo) echo "com.ground-base.nakasendo" ;;
    koshudo)   echo "com.ground-base.koshudo" ;;
    nikkodo)   echo "com.ground-base.nikkodo" ;;
    oshudo)    echo "com.ground-base.oshudo" ;;
  esac
}

bundle_android() {
  case "$1" in
    tokaido)   echo "com.groundbase.tokaido" ;;
    nakasendo) echo "com.groundbase.nakasendo" ;;
    koshudo)   echo "com.groundbase.koshudo" ;;
    nikkodo)   echo "com.groundbase.nikkodo" ;;
    oshudo)    echo "com.groundbase.oshudo" ;;
  esac
}

display_name() {
  case "$1" in
    tokaido)   echo "東海道五十三次" ;;
    nakasendo) echo "中山道六十九次" ;;
    koshudo)   echo "甲州道中四十四次" ;;
    nikkodo)   echo "日光道中二十一次" ;;
    oshudo)    echo "奥州道中十次" ;;
  esac
}

# ── ヘルパー ───────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()   { echo -e "${BLUE}[kaido]${NC} $1"; }
ok()    { echo -e "${GREEN}[  OK ]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN ]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
die()   { error "$1"; exit 1; }

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
  build   <app> <platform>    ビルドのみ（ストア提出なし）
  release <app> <platform>    ビルド + ストア提出
  version <app> <version>     バージョン番号を更新（app に all で全アプリ一括。
                              ビルド番号は全アプリ中の最大値+1 で統一採番）
  status                      認証情報のセットアップ状態を確認
  setup                       認証情報のセットアップ

Arguments:
  <app>       アプリ名: tokaido | nakasendo | koshudo | nikkodo | oshudo
  <platform>  プラットフォーム: ios | android | all

Examples:
  ./release/release.sh release tokaido ios       # 東海道 iOS をストアに提出
  ./release/release.sh release tokaido all       # 東海道 iOS + Android を提出
  ./release/release.sh build nakasendo android   # 中山道 Android をビルドのみ
  ./release/release.sh version all 4.1.0         # 全アプリのバージョンを 4.1.0 に更新
  ./release/release.sh version tokaido 4.1.0     # 東海道のみバージョンを 4.1.0 に更新
EOF
  exit 1
}

validate_app() {
  local app="$1"
  local found=false
  for a in "${ALL_APPS[@]}"; do
    [[ "$a" == "$app" ]] && found=true && break
  done
  $found || die "Unknown app: $app (available: ${ALL_APPS[*]})"
}

validate_platform() {
  local platform="$1"
  [[ "$platform" =~ ^(ios|android|all)$ ]] || die "Unknown platform: $platform (available: ios, android, all)"
}

# ── 認証情報チェック ───────────────────────────────────
check_ios_credentials() {
  local ok=true
  [[ -f "$CREDENTIALS_DIR/apple_api_key.p8" ]] || { warn "Apple API Key (.p8) が見つかりません"; ok=false; }
  [[ -f "$CREDENTIALS_DIR/apple_api_config.env" ]] || { warn "Apple API 設定ファイルが見つかりません"; ok=false; }
  $ok
}

check_android_credentials() {
  local ok=true
  [[ -f "$CREDENTIALS_DIR/google_play_service_account.json" ]] || { warn "Google Play Service Account JSON が見つかりません"; ok=false; }
  $ok
}

# ── セットアップ ───────────────────────────────────────
cmd_setup() {
  log "認証情報のセットアップを開始します"
  mkdir -p "$CREDENTIALS_DIR"

  cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  iOS (App Store Connect) セットアップ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. App Store Connect → ユーザーとアクセス → 統合 → App Store Connect API
2. 「キーを生成」をクリック
   - 名前: kaido-release
   - アクセス: App Manager
3. .p8 ファイルをダウンロード
4. 以下の情報を控える:
   - Key ID (例: A1B2C3D4E5)
   - Issuer ID (例: 12345678-1234-1234-1234-123456789012)

EOF

  read -rp "Apple API Key (.p8) ファイルのパス: " apple_key_path
  if [[ -n "$apple_key_path" && -f "$apple_key_path" ]]; then
    cp "$apple_key_path" "$CREDENTIALS_DIR/apple_api_key.p8"
    ok "Apple API Key を保存しました"
  else
    warn "スキップしました"
  fi

  read -rp "Key ID: " apple_key_id
  read -rp "Issuer ID: " apple_issuer_id
  if [[ -n "$apple_key_id" && -n "$apple_issuer_id" ]]; then
    cat > "$CREDENTIALS_DIR/apple_api_config.env" <<ENVEOF
APPLE_API_KEY_ID=${apple_key_id}
APPLE_API_ISSUER_ID=${apple_issuer_id}
APPLE_API_KEY_PATH=${CREDENTIALS_DIR}/apple_api_key.p8
ENVEOF
    ok "Apple API 設定を保存しました"
  fi

  cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Android (Google Play Console) セットアップ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Google Cloud Console → IAM → サービスアカウント
2. サービスアカウントを作成（ロール不要）
3. JSON キーを作成・ダウンロード
4. Google Play Console → 設定 → API アクセス
5. サービスアカウントをリンクし「リリース管理者」権限を付与

EOF

  read -rp "Google Play Service Account JSON ファイルのパス: " google_key_path
  if [[ -n "$google_key_path" && -f "$google_key_path" ]]; then
    cp "$google_key_path" "$CREDENTIALS_DIR/google_play_service_account.json"
    ok "Google Play Service Account を保存しました"
  else
    warn "スキップしました"
  fi

  echo ""
  log ".credentials/ を .gitignore に追加しています..."
  if ! grep -q ".credentials/" "$ROOT_DIR/.gitignore" 2>/dev/null; then
    echo ".credentials/" >> "$ROOT_DIR/.gitignore"
    ok ".gitignore に追加しました"
  else
    ok "既に .gitignore に含まれています"
  fi

  echo ""
  cmd_status
}

# ── ステータス ─────────────────────────────────────────
cmd_status() {
  log "認証情報の状態:"
  echo ""

  echo -n "  iOS   App Store Connect API Key: "
  [[ -f "$CREDENTIALS_DIR/apple_api_key.p8" ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"

  echo -n "  iOS   API 設定 (Key ID / Issuer): "
  [[ -f "$CREDENTIALS_DIR/apple_api_config.env" ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"

  echo -n "  Android Google Play Service Account: "
  [[ -f "$CREDENTIALS_DIR/google_play_service_account.json" ]] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"

  echo ""

  echo -n "  fastlane: "
  command -v fastlane >/dev/null 2>&1 && echo -e "${GREEN}✓ $(fastlane --version 2>/dev/null | head -1)${NC}" || echo -e "${RED}✗ 未インストール (gem install fastlane)${NC}"

  echo -n "  flutter:  "
  command -v flutter >/dev/null 2>&1 && echo -e "${GREEN}✓ $(flutter --version 2>/dev/null | head -1)${NC}" || echo -e "${RED}✗ 未インストール${NC}"

  echo ""
}

# ── バージョン更新 ─────────────────────────────────────
# ビルド番号は全アプリで統一する（Google Play の versionCode 要件を
# 満たすため、常に全アプリ中の最大ビルド番号 +1 を採番する）
max_build_number() {
  local max=0
  for a in "${ALL_APPS[@]}"; do
    local p="$ROOT_DIR/apps/$a/pubspec.yaml"
    [[ -f "$p" ]] || continue
    local b
    b=$(grep '^version:' "$p" | head -1 | grep -o '+[0-9]*' | tr -d '+')
    [[ -n "$b" && "$b" -gt "$max" ]] && max=$b
  done
  echo "$max"
}

update_app_version() {
  local app="$1"
  local new_version="$2"
  local new_build="$3"

  local pubspec="$ROOT_DIR/apps/$app/pubspec.yaml"
  [[ -f "$pubspec" ]] || die "pubspec.yaml が見つかりません: $pubspec"

  local current
  current=$(grep '^version:' "$pubspec" | head -1 | sed 's/version: *//')
  sed -i '' "s/^version: .*/version: ${new_version}+${new_build}/" "$pubspec"
  ok "$(display_name "$app"): $current → ${new_version}+${new_build}"
}

cmd_version() {
  local app="$1"
  local new_version="$2"

  local new_build
  new_build=$(( $(max_build_number) + 1 ))

  if [[ "$app" == "all" ]]; then
    log "全アプリのバージョンを ${new_version}+${new_build} に更新します"
    for a in "${ALL_APPS[@]}"; do
      update_app_version "$a" "$new_version" "$new_build"
    done
  else
    validate_app "$app"
    update_app_version "$app" "$new_version" "$new_build"
  fi
}

# ── ビルド ─────────────────────────────────────────────
build_ios() {
  local app="$1"
  local app_dir="$ROOT_DIR/apps/$app"

  log "iOS ビルド開始: $(display_name "$app")"
  cd "$app_dir"

  flutter build ipa \
    --release \
    --dart-define-from-file="$ROOT_DIR/env/production.json" \
    --export-options-plist="$app_dir/ios/ExportOptions.plist" \
    2>&1 | while IFS= read -r line; do echo "  $line"; done

  local ipa_path
  ipa_path=$(find "$app_dir/build/ios/ipa" -name "*.ipa" -type f 2>/dev/null | head -1)
  [[ -n "$ipa_path" ]] || die "IPA ファイルが見つかりません"

  ok "iOS ビルド完了: $ipa_path"
  echo "$ipa_path"
}

build_android() {
  local app="$1"
  local app_dir="$ROOT_DIR/apps/$app"

  # Gradle には Java が必要。未設定なら brew の OpenJDK を使う
  if [[ -z "${JAVA_HOME:-}" && -d "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home" ]]; then
    export JAVA_HOME="/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
  fi

  log "Android ビルド開始: $(display_name "$app")"
  cd "$app_dir"

  flutter build appbundle \
    --release \
    --dart-define-from-file="$ROOT_DIR/env/production.json" \
    2>&1 | while IFS= read -r line; do echo "  $line"; done

  local aab_path="$app_dir/build/app/outputs/bundle/release/app-release.aab"
  [[ -f "$aab_path" ]] || die "AAB ファイルが見つかりません: $aab_path"

  ok "Android ビルド完了: $aab_path"
  echo "$aab_path"
}

# ── ストア提出 ─────────────────────────────────────────
upload_ios() {
  local app="$1"
  local ipa_path="$2"

  check_ios_credentials || die "iOS 認証情報が未設定です。先に ./scripts/release.sh setup を実行してください"
  source "$CREDENTIALS_DIR/apple_api_config.env"

  log "App Store Connect にアップロード中: $(display_name "$app")"

  xcrun altool --upload-app \
    --type ios \
    --file "$ipa_path" \
    --apiKey "$APPLE_API_KEY_ID" \
    --apiIssuer "$APPLE_API_ISSUER_ID" \
    2>&1 | while IFS= read -r line; do echo "  $line"; done

  ok "App Store Connect へのアップロード完了"
}

upload_android() {
  local app="$1"
  local aab_path="$2"
  local package_name="$(bundle_android "$app")"

  check_android_credentials || die "Android 認証情報が未設定です。先に ./scripts/release.sh setup を実行してください"

  command -v fastlane >/dev/null 2>&1 || die "fastlane が必要です: gem install fastlane"

  log "Google Play Console にアップロード中: $(display_name "$app")"

  fastlane supply \
    --aab "$aab_path" \
    --package_name "$package_name" \
    --track internal \
    --json_key "$CREDENTIALS_DIR/google_play_service_account.json" \
    --skip_upload_metadata \
    --skip_upload_changelogs \
    --skip_upload_images \
    --skip_upload_screenshots \
    2>&1 | while IFS= read -r line; do echo "  $line"; done

  ok "Google Play Console へのアップロード完了（内部テストトラック）"
}

# ── メインコマンド ─────────────────────────────────────
cmd_build() {
  local app="$1"
  local platform="$2"
  validate_app "$app"
  validate_platform "$platform"

  log "━━━ ビルド: $(display_name "$app") ($platform) ━━━"

  if [[ "$platform" == "ios" || "$platform" == "all" ]]; then
    build_ios "$app"
  fi
  if [[ "$platform" == "android" || "$platform" == "all" ]]; then
    build_android "$app"
  fi

  ok "ビルド完了: $(display_name "$app")"
}

cmd_release() {
  local app="$1"
  local platform="$2"
  validate_app "$app"
  validate_platform "$platform"

  log "━━━ リリース: $(display_name "$app") ($platform) ━━━"
  echo ""

  # バージョン確認
  local pubspec="$ROOT_DIR/apps/$app/pubspec.yaml"
  if [[ -f "$pubspec" ]]; then
    local version
    version=$(grep '^version:' "$pubspec" | head -1 | sed 's/version: *//')
    log "バージョン: $version"
  fi

  # 確認プロンプト
  read -rp "$(echo -e "${YELLOW}リリースを続行しますか？ [y/N]: ${NC}")" confirm
  [[ "$confirm" =~ ^[yY]$ ]] || { log "キャンセルしました"; exit 0; }
  echo ""

  if [[ "$platform" == "ios" || "$platform" == "all" ]]; then
    local ipa_path
    ipa_path=$(build_ios "$app")
    upload_ios "$app" "$ipa_path"
    echo ""
  fi

  if [[ "$platform" == "android" || "$platform" == "all" ]]; then
    local aab_path
    aab_path=$(build_android "$app")
    upload_android "$app" "$aab_path"
    echo ""
  fi

  ok "━━━ リリース完了: $(display_name "$app") ($platform) ━━━"
}

# ── エントリポイント ───────────────────────────────────
[[ $# -ge 1 ]] || usage

case "$1" in
  build)
    [[ $# -ge 3 ]] || die "Usage: $(basename "$0") build <app> <platform>"
    cmd_build "$2" "$3"
    ;;
  release)
    [[ $# -ge 3 ]] || die "Usage: $(basename "$0") release <app> <platform>"
    cmd_release "$2" "$3"
    ;;
  version)
    [[ $# -ge 3 ]] || die "Usage: $(basename "$0") version <app> <version>"
    cmd_version "$2" "$3"
    ;;
  status)
    cmd_status
    ;;
  setup)
    cmd_setup
    ;;
  *)
    usage
    ;;
esac
