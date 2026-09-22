#!/usr/bin/env bash

set -euo pipefail

TPM_DIR="$HOME/.tmux/plugins/tpm"

CATPPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin/tmux"
CATPPUCCIN_VERSION="v2.1.3"

# --------------------------------------------------
# TPM
# --------------------------------------------------

if [[ ! -d "$TPM_DIR/.git" ]]; then
  echo "Installing TPM..."

  mkdir -p "$(dirname "$TPM_DIR")"

  git clone \
    https://github.com/tmux-plugins/tpm \
    "$TPM_DIR"
else
  echo "TPM is already installed."
fi

# --------------------------------------------------
# Catppuccin
# --------------------------------------------------

if [[ ! -d "$CATPPUCCIN_DIR/.git" ]]; then
  echo "Installing Catppuccin tmux..."

  mkdir -p "$(dirname "$CATPPUCCIN_DIR")"

  git clone \
    --branch "$CATPPUCCIN_VERSION" \
    --depth 1 \
    https://github.com/catppuccin/tmux.git \
    "$CATPPUCCIN_DIR"
else
  echo "Updating Catppuccin tmux to $CATPPUCCIN_VERSION..."

  git -C "$CATPPUCCIN_DIR" fetch \
    --depth 1 \
    origin \
    "refs/tags/$CATPPUCCIN_VERSION:refs/tags/$CATPPUCCIN_VERSION"

  git -C "$CATPPUCCIN_DIR" checkout "$CATPPUCCIN_VERSION"
fi
