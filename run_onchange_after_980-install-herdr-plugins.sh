#!/usr/bin/env bash
set -euo pipefail

command -v herdr >/dev/null 2>&1 || {
  echo "herdr is not installed"
  exit 1
}

herdr plugin install \
  bojackduy/nvim-herdr-navigation/herdr-vim-navigator \
  --yes
