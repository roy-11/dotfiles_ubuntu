#!/usr/bin/env bash

set -euo pipefail

KEYRING="/etc/apt/keyrings/githubcli-archive-keyring.gpg"
SOURCE_FILE="/etc/apt/sources.list.d/github-cli.sources"

# --------------------------------------------------
# GitHub CLI official repository
# --------------------------------------------------

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL \
  https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  -o "$KEYRING"

sudo chmod a+r "$KEYRING"

sudo tee "$SOURCE_FILE" >/dev/null <<EOF
Types: deb
URIs: https://cli.github.com/packages
Suites: stable
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: ${KEYRING}
EOF

# --------------------------------------------------
# Install (Ubuntu版が入っていれば公式版に置き換わる)
# --------------------------------------------------

sudo apt update
sudo apt install -y gh
