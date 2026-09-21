#!/usr/bin/env bash

set -euo pipefail

ANKI_VERSION="26.09.2"
ARCH="x86_64"

# 必要ライブラリ
# sudo apt update
# sudo apt install -y \
#   zstd \
#   libxcb-xinerama0 \
#   libxcb-cursor0 \
#   libnss3 \
#   libxcb-icccm4 \
#   libxcb-keysyms1

# すでに指定バージョンが入っていれば何もしない
if command -v anki >/dev/null 2>&1; then
  installed_version="$(anki --version 2>/dev/null | head -n1 || true)"

  if [[ "$installed_version" == *"$ANKI_VERSION"* ]]; then
    echo "Anki $ANKI_VERSION is already installed."
    exit 0
  fi
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

archive="anki-${ANKI_VERSION}-linux-${ARCH}.tar.zst"

url="https://github.com/ankitects/anki/releases/download/${ANKI_VERSION}/${archive}"

echo "Downloading Anki ${ANKI_VERSION}..."

curl -fL \
  "$url" \
  -o "$tmp_dir/$archive"

echo "Extracting..."

tar xaf "$tmp_dir/$archive" -C "$tmp_dir"

install_dir="$(find "$tmp_dir" -maxdepth 1 -type d -name 'anki-*linux*' | head -n1)"

if [[ -z "$install_dir" ]]; then
  echo "Anki install directory not found."
  exit 1
fi

echo "Installing Anki..."

cd "$install_dir"
sudo ./install.sh

echo "Anki ${ANKI_VERSION} installation completed."
