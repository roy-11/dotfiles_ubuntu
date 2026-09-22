#!/usr/bin/env bash

set -euo pipefail

KEYRING="/usr/share/keyrings/claude-desktop-archive-keyring.asc"
SOURCE_LIST="/etc/apt/sources.list.d/claude-desktop.list"
REPO_URL="https://downloads.claude.ai/claude-desktop/apt/stable"

# --------------------------------------------------
# Architecture check
# --------------------------------------------------

ARCH="$(dpkg --print-architecture)"

case "$ARCH" in
amd64 | arm64)
  ;;
*)
  echo "Unsupported architecture: $ARCH"
  exit 1
  ;;
esac

# --------------------------------------------------
# Repository signing key
# --------------------------------------------------

echo "Installing Claude Desktop repository key..."

sudo curl -fsSLo \
  "$KEYRING" \
  https://downloads.claude.ai/claude-desktop/key.asc

# --------------------------------------------------
# Repository
# --------------------------------------------------

echo "Configuring Claude Desktop repository..."

echo \
  "deb [signed-by=${KEYRING}] ${REPO_URL} stable main" |
  sudo tee "$SOURCE_LIST" >/dev/null

# --------------------------------------------------
# Install
# --------------------------------------------------

sudo apt update
sudo apt install -y claude-desktop

echo "Claude Desktop installation completed."
