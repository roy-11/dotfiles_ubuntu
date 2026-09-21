#!/usr/bin/env bash
set -eu

# desktop file hash:
# {{ include "dot_local/share/applications/chatgpt.desktop" | sha256sum }}

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications"
fi
