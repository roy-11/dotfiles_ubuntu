#!/usr/bin/env bash

set -euo pipefail

echo "==> Setting up AWS Session Manager plugin"

if command -v session-manager-plugin >/dev/null 2>&1; then
  echo "Session Manager plugin is already installed:"
  session-manager-plugin --version
  exit 0
fi

ARCH="$(dpkg --print-architecture)"

case "$ARCH" in
amd64)
  PLATFORM="ubuntu_64bit"
  ;;
arm64)
  PLATFORM="ubuntu_arm64"
  ;;
*)
  echo "Unsupported architecture: $ARCH"
  exit 1
  ;;
esac

tmp_deb="$(mktemp --suffix=.deb)"
trap 'rm -f "$tmp_deb"' EXIT

curl -fL \
  "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/${PLATFORM}/session-manager-plugin.deb" \
  -o "$tmp_deb"

sudo dpkg -i "$tmp_deb"

echo "==> Session Manager plugin installed"
session-manager-plugin --version
