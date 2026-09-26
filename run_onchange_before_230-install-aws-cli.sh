#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up AWS CLI"

if command -v aws >/dev/null 2>&1; then
  echo "AWS CLI is already installed:"
  aws --version
  exit 0
fi

# AWS公式 installer
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash

echo "==> AWS CLI installed"
"$HOME/.local/bin/aws" --version
