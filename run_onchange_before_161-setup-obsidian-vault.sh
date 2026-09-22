#!/usr/bin/env bash

set -euo pipefail

VAULT_DIR="$HOME/obsidian_git"
REPO_URL="git@github.com:roy-11/obsidian.git"

# Gitが必要
if ! command -v git >/dev/null 2>&1; then
  echo "git is not installed."
  exit 1
fi

# すでに正しいGit repositoryがある
if [[ -d "$VAULT_DIR/.git" ]]; then
  echo "Obsidian vault already exists:"
  echo "  $VAULT_DIR"

  CURRENT_REMOTE="$(git -C "$VAULT_DIR" remote get-url origin 2>/dev/null || true)"

  if [[ "$CURRENT_REMOTE" != "$REPO_URL" ]]; then
    echo "Warning: origin differs from expected repository."
    echo "Current:  $CURRENT_REMOTE"
    echo "Expected: $REPO_URL"
  fi

  exit 0
fi

# Git repoではない既存ディレクトリがある場合は破壊しない
if [[ -e "$VAULT_DIR" ]]; then
  echo "Error: $VAULT_DIR already exists but is not a Git repository."
  echo "Move or remove it manually before continuing."
  exit 1
fi

echo "Cloning Obsidian vault..."

git clone "$REPO_URL" "$VAULT_DIR"

echo
echo "Obsidian vault cloned:"
echo "  $VAULT_DIR"
