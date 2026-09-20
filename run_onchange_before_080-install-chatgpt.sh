#!/usr/bin/env bash

set -euo pipefail

if ! command -v chatgpt >/dev/null 2>&1; then
  tmp_deb="$(mktemp --suffix=.deb)"

  curl -fL \
    https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb \
    -o "$tmp_deb"

  sudo apt install -y "$tmp_deb"
  rm -f "$tmp_deb"
fi
