#!/usr/bin/env bash

set -euo pipefail

if command -v espanso >/dev/null 2>&1; then
  echo "Espanso is already installed."
  exit 0
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

deb_path="$tmp_dir/espanso-debian-wayland-amd64.deb"

echo "Downloading Espanso Wayland package..."

wget \
  -O "$deb_path" \
  https://github.com/espanso/espanso/releases/latest/download/espanso-debian-wayland-amd64.deb

echo "Installing Espanso..."

sudo apt install -y "$deb_path"

echo "Espanso installation completed."
