#!/usr/bin/env bash
set -euo pipefail

# espanso 本体は run_onchange_before_120 でインストール済み
# 設定ファイル（match/*.yml）の配置後に起動するため after で実行する

command -v espanso >/dev/null 2>&1 || {
  echo "espanso is not installed"
  exit 1
}

# 自動起動（systemd user service）に登録
espanso service check >/dev/null 2>&1 || espanso service register

# 起動していなければ起動
espanso status >/dev/null 2>&1 || espanso start
