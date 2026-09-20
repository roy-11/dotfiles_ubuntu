#!/usr/bin/env bash

set -euo pipefail

if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
  echo "Chrome/Vivaldi bootstrap currently supports amd64 only."
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

# --------------------------------------------------
# Google Chrome
# --------------------------------------------------

if ! command -v google-chrome-stable >/dev/null 2>&1; then
  echo "Installing Google Chrome..."

  curl -fL \
    https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    -o "$tmp_dir/google-chrome.deb"

  sudo apt install -y "$tmp_dir/google-chrome.deb"
fi

# --------------------------------------------------
# Vivaldi
# --------------------------------------------------

if ! command -v vivaldi-stable >/dev/null 2>&1; then
  echo "Installing Vivaldi..."

  curl -fL \
    https://vivaldi.com/download/vivaldi-stable_amd64.deb \
    -o "$tmp_dir/vivaldi.deb"

  sudo apt install -y "$tmp_dir/vivaldi.deb"
fi

# .deb installation registers vendor repositories.
# Refresh APT indexes so they are immediately visible to APT.
sudo apt update
