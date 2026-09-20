#!/usr/bin/env bash

set -euo pipefail

FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerd"

if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
  mkdir -p "$FONT_DIR"

  curl -fsSL \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz |
    tar -xJ -C "$FONT_DIR"

  fc-cache -f
fi
