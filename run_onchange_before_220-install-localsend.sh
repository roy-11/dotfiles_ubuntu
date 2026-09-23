#!/usr/bin/env bash

set -euo pipefail

ARCH="$(dpkg --print-architecture)"

case "$ARCH" in
amd64)
  ASSET_SUFFIX="linux-x86-64.deb"
  ;;
arm64)
  ASSET_SUFFIX="linux-arm-64.deb"
  ;;
*)
  echo "Unsupported architecture: $ARCH"
  exit 1
  ;;
esac

echo "==> Finding latest LocalSend release..."

RELEASE_JSON="$(curl -fsSL \
  https://api.github.com/repos/localsend/localsend/releases/latest)"

DOWNLOAD_URL="$(
  printf '%s' "$RELEASE_JSON" |
    jq -r \
      --arg suffix "$ASSET_SUFFIX" \
      '.assets[]
       | select(.name | endswith($suffix))
       | .browser_download_url' |
    head -n 1
)"

if [[ -z "$DOWNLOAD_URL" || "$DOWNLOAD_URL" == "null" ]]; then
  echo "Could not find LocalSend .deb for architecture: $ARCH"
  exit 1
fi

tmp_deb="$(mktemp --suffix=.deb)"
trap 'rm -f "$tmp_deb"' EXIT

echo "==> Downloading LocalSend..."

curl -fL "$DOWNLOAD_URL" -o "$tmp_deb"

echo "==> Installing LocalSend..."

sudo apt install -y "$tmp_deb"

echo "==> LocalSend installation completed."
