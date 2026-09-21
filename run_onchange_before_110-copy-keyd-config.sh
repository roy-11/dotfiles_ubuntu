#!/usr/bin/env bash

set -euo pipefail

sudo install -m 644 \
  "$HOME/.local/share/chezmoi/keyd/default.conf" \
  /etc/keyd/default.conf

sudo systemctl enable --now keyd
sudo keyd.rvaiya reload
