#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up CodeRabbit CLI"

if command -v coderabbit >/dev/null 2>&1 || [ -x "$HOME/.local/bin/coderabbit" ]; then
  echo "CodeRabbit CLI is already installed"
  exit 0
fi

# CodeRabbit公式 installer (~/.local/bin/coderabbit と alias cr を配置)
curl -fsSL https://cli.coderabbit.ai/install.sh | sh

echo "==> CodeRabbit CLI installed"
"$HOME/.local/bin/coderabbit" --version
