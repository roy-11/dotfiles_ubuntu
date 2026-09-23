#!/usr/bin/env bash

set -euo pipefail

echo "==> Installing CLIAMP runtime dependencies..."

sudo apt update

sudo apt install -y \
  ffmpeg \
  python3-secretstorage

echo "==> Installing CLIAMP..."

tmp_installer="$(mktemp)"
trap 'rm -f "$tmp_installer"' EXIT

curl -fsSL \
  https://cliamp.stream/install.sh \
  -o "$tmp_installer"

sh "$tmp_installer"

echo "==> CLIAMP installation completed."
