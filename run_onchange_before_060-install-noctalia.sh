#!/usr/bin/env bash

set -euo pipefail

KEYRING_PACKAGE="nickh-archive-keyring"
SOURCE_FILE="/etc/apt/sources.list.d/noctalia-resolute.sources"
SOURCE_URL="https://pkg.noctalia.dev/deb/noctalia-resolute.sources"

# --------------------------------------------------
# Repository signing key
# --------------------------------------------------

if ! dpkg-query -W -f='${Status}' "$KEYRING_PACKAGE" 2>/dev/null |
  grep -q "ok installed"; then

  echo "Installing Noctalia repository signing key..."

  tmp_deb="$(mktemp --suffix=.deb)"
  trap 'rm -f "$tmp_deb"' EXIT

  curl -fL \
    https://pkg.noctalia.dev/deb/nickh-archive-keyring.deb \
    -o "$tmp_deb"

  sudo dpkg -i "$tmp_deb"
else
  echo "$KEYRING_PACKAGE is already installed."
fi

# --------------------------------------------------
# Repository
# --------------------------------------------------

echo "Configuring Noctalia repository..."

curl -fsSL "$SOURCE_URL" |
  sudo tee "$SOURCE_FILE" >/dev/null

# --------------------------------------------------
# Install
# --------------------------------------------------

sudo apt update
sudo apt install -y noctalia
