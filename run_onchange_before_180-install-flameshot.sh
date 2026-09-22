#!/usr/bin/env bash

set -euo pipefail

sudo apt update

sudo apt install -y \
  flameshot \
  grim

echo "Flameshot installation completed."
