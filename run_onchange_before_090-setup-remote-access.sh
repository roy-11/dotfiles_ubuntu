#!/usr/bin/env bash

set -euo pipefail

. /etc/os-release

if [[ "${ID:-}" != "ubuntu" ]]; then
  echo "This script supports Ubuntu only."
  exit 1
fi

CODENAME="${VERSION_CODENAME:?VERSION_CODENAME is not set}"

# --------------------------------------------------
# Tailscale repository
# --------------------------------------------------

sudo install -d -m 0755 /usr/share/keyrings

curl -fsSL \
  "https://pkgs.tailscale.com/stable/ubuntu/${CODENAME}.noarmor.gpg" |
  sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg \
    >/dev/null

curl -fsSL \
  "https://pkgs.tailscale.com/stable/ubuntu/${CODENAME}.tailscale-keyring.list" |
  sudo tee /etc/apt/sources.list.d/tailscale.list \
    >/dev/null

# --------------------------------------------------
# Install
# --------------------------------------------------

sudo apt update

sudo apt install -y \
  tailscale \
  openssh-server

# --------------------------------------------------
# Services
# --------------------------------------------------

sudo systemctl enable --now tailscaled
sudo systemctl enable --now ssh

echo
echo "Remote access setup completed."
echo
echo "Tailscale authentication is intentionally NOT automated."
echo "Run manually:"
echo
echo "  sudo tailscale up"
echo
