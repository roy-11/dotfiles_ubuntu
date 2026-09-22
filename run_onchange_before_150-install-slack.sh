#!/usr/bin/env bash

set -euo pipefail

PACKAGE="slack-desktop"

# --------------------------------------------------
# Architecture check
# --------------------------------------------------

ARCH="$(dpkg --print-architecture)"

if [[ "$ARCH" != "amd64" ]]; then
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# --------------------------------------------------
# Already installed
# --------------------------------------------------

if dpkg-query -W -f='${Status}' "$PACKAGE" 2>/dev/null |
  grep -q "ok installed"; then

  echo "Slack is already installed."

  # Repository metadata may have changed, so keep APT fresh.
  sudo apt update

  exit 0
fi

# --------------------------------------------------
# Resolve latest Slack .deb URL
# --------------------------------------------------

echo "Resolving latest Slack version..."

DOWNLOAD_PAGE="https://slack.com/downloads/instructions/linux?build=deb&ddl=1"

DEB_URL="$(
  curl -fsSL "$DOWNLOAD_PAGE" |
    grep -oE \
      'https://downloads\.slack-edge\.com/desktop-releases/linux/x64/[0-9.]+/slack-desktop-[0-9.]+-amd64\.deb' |
    head -n 1
)"

if [[ -z "$DEB_URL" ]]; then
  echo "Failed to resolve Slack download URL."
  exit 1
fi

echo "Downloading:"
echo "  $DEB_URL"

# --------------------------------------------------
# Download / install
# --------------------------------------------------

tmp_deb="$(mktemp --suffix=.deb)"
trap 'rm -f "$tmp_deb"' EXIT

curl -fL "$DEB_URL" -o "$tmp_deb"

sudo apt install -y "$tmp_deb"

# --------------------------------------------------
# Refresh APT repository
# --------------------------------------------------

sudo apt update

echo "Slack installation completed."
