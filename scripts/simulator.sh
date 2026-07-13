#!/usr/bin/env bash
#
# Android エミュレータ / iOS シミュレータの起動・停止
#
# 使い方:
#   scripts/simulator.sh                    # 両方起動
#   scripts/simulator.sh start [android|ios|all]
#   scripts/simulator.sh stop  [android|ios|all]
#   scripts/simulator.sh status            # 起動状態を表示
#
# 環境変数:
#   AVD_NAME     使用する Android AVD 名（デフォルト: 最初に見つかった AVD）
#   IOS_DEVICE   使用する iOS デバイス名（デフォルト: 最初に見つかった iPhone）

set -euo pipefail

ANDROID_SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
EMULATOR="$ANDROID_SDK/emulator/emulator"
ADB="$ANDROID_SDK/platform-tools/adb"

log() { printf '\033[1;34m[simulator]\033[0m %s\n' "$*"; }
err() { printf '\033[1;31m[simulator]\033[0m %s\n' "$*" >&2; }

start_android() {
  if [[ ! -x "$EMULATOR" ]]; then
    err "Android SDK が見つかりません: $EMULATOR"
    err "ANDROID_HOME を設定するか Android Studio で SDK をインストールしてください"
    return 1
  fi

  if "$ADB" devices | grep -q '^emulator-.*device$'; then
    log "Android エミュレータは既に起動しています"
    return 0
  fi

  local avd="${AVD_NAME:-$("$EMULATOR" -list-avds | head -1)}"
  if [[ -z "$avd" ]]; then
    err "AVD がありません。Android Studio の Device Manager で作成してください"
    return 1
  fi

  log "Android エミュレータを起動します: $avd"
  nohup "$EMULATOR" -avd "$avd" >/dev/null 2>&1 &
  disown

  log "ブート完了を待機中..."
  "$ADB" wait-for-device
  until [[ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do
    sleep 2
  done
  log "Android エミュレータの起動が完了しました"
}

stop_android() {
  local serials
  serials=$("$ADB" devices 2>/dev/null | awk '/^emulator-/ && $2 == "device" {print $1}')
  if [[ -z "$serials" ]]; then
    log "起動中の Android エミュレータはありません"
    return 0
  fi
  local s
  for s in $serials; do
    log "Android エミュレータを停止します: $s"
    "$ADB" -s "$s" emu kill >/dev/null
  done
  log "Android エミュレータを停止しました"
}

start_ios() {
  if ! xcrun simctl list runtimes 2>/dev/null | grep -q 'iOS'; then
    err "iOS シミュレータランタイムがありません。以下を実行してください:"
    err "  xcodebuild -downloadPlatform iOS"
    return 1
  fi

  local booted
  booted=$(xcrun simctl list devices | grep '(Booted)' || true)
  if [[ -n "$booted" ]]; then
    log "iOS シミュレータは既に起動しています:"
    echo "$booted"
    open -a Simulator
    return 0
  fi

  local device="${IOS_DEVICE:-}"
  local udid
  if [[ -n "$device" ]]; then
    udid=$(xcrun simctl list devices available | grep "$device (" | head -1 | grep -oE '[0-9A-F-]{36}')
  else
    udid=$(xcrun simctl list devices available | grep -E '^\s+iPhone' | head -1 | grep -oE '[0-9A-F-]{36}')
  fi

  if [[ -z "${udid:-}" ]]; then
    err "利用可能な iOS シミュレータが見つかりません"
    return 1
  fi

  log "iOS シミュレータを起動します: $(xcrun simctl list devices | grep "$udid" | sed -E 's/^ +//; s/ \(.*//')"
  xcrun simctl boot "$udid"
  open -a Simulator

  log "ブート完了を待機中..."
  xcrun simctl bootstatus "$udid" >/dev/null
  log "iOS シミュレータの起動が完了しました"
}

stop_ios() {
  if ! xcrun simctl list devices 2>/dev/null | grep -q '(Booted)'; then
    log "起動中の iOS シミュレータはありません"
  else
    log "iOS シミュレータを停止します"
    xcrun simctl shutdown all
    log "iOS シミュレータを停止しました"
  fi
  # Simulator.app のウィンドウも閉じる（起動していなければ何もしない）
  osascript -e 'tell application "System Events" to (name of processes) contains "Simulator"' \
    | grep -q true && osascript -e 'quit app "Simulator"' >/dev/null || true
}

show_status() {
  log "Android エミュレータ:"
  if "$ADB" devices 2>/dev/null | grep '^emulator-' ; then :; else echo "    (なし)"; fi
  log "iOS シミュレータ:"
  xcrun simctl list devices 2>/dev/null | grep '(Booted)' || echo "    (なし)"
}

cmd="${1:-start}"
case "$cmd" in
  android|ios|all) target="$cmd"; cmd="start" ;;  # 後方互換: simulator.sh android
  start|stop)      target="${2:-all}" ;;
  status)          show_status; exit 0 ;;
  *)
    err "不明なコマンド: $cmd"
    err "使い方: simulator.sh [start|stop|status] [android|ios|all]"
    exit 1
    ;;
esac

case "$target" in
  android) "${cmd}_android" ;;
  ios)     "${cmd}_ios" ;;
  all)     "${cmd}_android"; "${cmd}_ios" ;;
  *)
    err "不明なターゲット: $target（android / ios / all のいずれか）"
    exit 1
    ;;
esac
