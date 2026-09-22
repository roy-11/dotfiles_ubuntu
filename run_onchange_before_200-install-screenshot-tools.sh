#!/usr/bin/env bash

set -euo pipefail

# --------------------------------------------------
# Wayland screenshot tools
# --------------------------------------------------

sudo apt update

sudo apt install -y \
  grim \
  slurp \
  wl-clipboard \
  curl

# --------------------------------------------------
# Satty
# --------------------------------------------------

if command -v satty >/dev/null 2>&1; then
  echo "Satty is already installed."
  exit 0
fi

ARCH="$(uname -m)"

if [[ "$ARCH" != "x86_64" ]]; then
  echo "Unsupported architecture for prebuilt Satty binary: $ARCH"
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

echo "Resolving latest Satty release..."

SATTTY_URL="$(
  curl -fsSL \
    https://api.github.com/repos/Satty-org/Satty/releases/latest |
    grep '"browser_download_url"' |
    cut -d '"' -f 4 |
    grep -E 'x86_64|amd64' |
    grep -v '\.flatpak$' |
    head -n 1
)"

if [[ -z "$SATTTY_URL" ]]; then
  echo "Failed to resolve Satty x86_64 release asset."
  exit 1
fi

echo "Downloading:"
echo "  $SATTTY_URL"

archive="$tmp_dir/$(basename "$SATTTY_URL")"

curl -fL \
  "$SATTTY_URL" \
  -o "$archive"

case "$archive" in
*.tar.gz | *.tgz)
  tar xzf "$archive" -C "$tmp_dir"
  ;;
*.tar.xz)
  tar xJf "$archive" -C "$tmp_dir"
  ;;
*.zip)
  sudo apt install -y unzip
  unzip -q "$archive" -d "$tmp_dir"
  ;;
*)
  # Prebuilt asset may itself be the binary.
  chmod +x "$archive"
  sudo install -Dm755 "$archive" /usr/local/bin/satty

  echo "Satty installation completed."
  exit 0
  ;;
esac

satty_bin="$(
  find "$tmp_dir" \
    -type f \
    -name satty \
    -perm -u+x |
    head -n 1
)"

if [[ -z "$satty_bin" ]]; then
  echo "Satty binary was not found in release archive."
  exit 1
fi

sudo install -Dm755 \
  "$satty_bin" \
  /usr/local/bin/satty

echo "Satty installation completed."
