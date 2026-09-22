#!/usr/bin/env bash

set -euo pipefail

OBSIDIAN_VERSION="1.13.7"

ARCH="$(dpkg --print-architecture)"

if [[ "$ARCH" != "amd64" ]]; then
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

PACKAGE="obsidian"

# 指定バージョンがすでに入っていれば終了
if dpkg-query -W -f='${Version}' "$PACKAGE" >/dev/null 2>&1; then
  INSTALLED_VERSION="$(dpkg-query -W -f='${Version}' "$PACKAGE")"

  if [[ "$INSTALLED_VERSION" == "$OBSIDIAN_VERSION"* ]]; then
    echo "Obsidian $INSTALLED_VERSION is already installed."
    exit 0
  fi
fi

tmp_deb="$(mktemp --suffix=.deb)"
trap 'rm -f "$tmp_deb"' EXIT

URL="https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb"

echo "Downloading Obsidian ${OBSIDIAN_VERSION}..."

curl -fL "$URL" -o "$tmp_deb"

echo "Installing Obsidian..."

sudo apt install -y "$tmp_deb"

echo "Obsidian ${OBSIDIAN_VERSION} installed."
