#!/usr/bin/env bash

set -euo pipefail

sudo apt update

# 'xterm-kitty': unknown terminal type 対策
sudo apt install -y \
  git \
  curl \
  unzip \
  build-essential \
  tmux \
  neovim \
  bat \
  fzf \
  zoxide \
  ripgrep \
  fd-find \
  wl-clipboard \
  kitty-terminfo \
  tree-sitter-cli \
  eza \
  fonts-noto-cjk \
  fonts-noto-cjk-extra \
  language-pack-ja \
  language-pack-gnome-ja \
  fcitx5 \
  fcitx5-mozc \
  fcitx5-config-qt \
  keyd \
  git-delta \
  lazygit \
  btop \
  mpv \
  manpages-ja \
  manpages-ja-dev \
  file \
  ffmpeg \
  7zip \
  jq \
  poppler-utils \
  imagemagick \
  btop \
  fastfetch \
  mpv \
  manpages-ja \
  manpages-ja-dev \
  file \
  ffmpeg \
  7zip \
  jq \
  poppler-utils \
  imagemagick \
  resvg

sudo update-locale LANG=ja_JP.UTF-8

mkdir -p "$HOME/.local/bin"

# Ubuntuではfd-findの実体がfdfind
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# Ubuntuのバージョンによってbatcatの場合に吸収
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi
