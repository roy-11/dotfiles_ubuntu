#!/usr/bin/env bash

set -euo pipefail

# https://github.com/peteonrails/voxtype
VOXTYPE_VERSION="1.1.0"

ARCH="$(dpkg --print-architecture)"

if [[ "$ARCH" != "amd64" ]]; then
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# --------------------------------------------------
# Runtime dependencies
# wtype: Wayland 入力（CJK対応） / wl-clipboard: クリップボードfallback
# libnotify-bin: 通知 / pipewire-alsa: ALSA経由の録音に必要
# libvulkan1: GPU(Vulkan)バックエンド用 / libgtk4-layer-shell0: 録音中の波形OSD用
# --------------------------------------------------

echo "==> Installing voxtype runtime dependencies..."

sudo apt update
sudo apt install -y \
  wtype \
  wl-clipboard \
  libnotify-bin \
  pipewire-alsa \
  libvulkan1 \
  libgtk4-layer-shell0

# --------------------------------------------------
# voxtype (.deb)
# --------------------------------------------------

PACKAGE="voxtype"

# 指定バージョンがすでに入っていればダウンロードをスキップ
INSTALLED_VERSION="$(dpkg-query -W -f='${Version}' "$PACKAGE" 2>/dev/null || true)"

if [[ "$INSTALLED_VERSION" == "$VOXTYPE_VERSION"* ]]; then
  echo "voxtype $INSTALLED_VERSION is already installed."
else
  tmp_deb="$(mktemp --suffix=.deb)"
  trap 'rm -f "$tmp_deb"' EXIT

  URL="https://github.com/peteonrails/voxtype/releases/download/v${VOXTYPE_VERSION}/voxtype_${VOXTYPE_VERSION}-1_amd64.deb"

  echo "==> Downloading voxtype ${VOXTYPE_VERSION}..."

  curl -fL "$URL" -o "$tmp_deb"

  echo "==> Installing voxtype..."

  sudo apt install -y "$tmp_deb"

  echo "==> voxtype ${VOXTYPE_VERSION} installed."
fi

# --------------------------------------------------
# GPU (Vulkan) バックエンドに切り替え
# --------------------------------------------------

echo "==> Enabling voxtype GPU (Vulkan) backend..."

sudo voxtype setup gpu --enable

echo "    初回のみ: voxtype setup model && systemctl --user enable --now voxtype"
