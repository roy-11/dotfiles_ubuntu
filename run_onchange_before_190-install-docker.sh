#!/usr/bin/env bash

set -euo pipefail

# --------------------------------------------------
# Dependencies
# --------------------------------------------------

sudo apt update
sudo apt install -y ca-certificates curl

# --------------------------------------------------
# Remove conflicting packages if installed
# --------------------------------------------------

conflicting_packages=(
  docker.io
  docker-compose
  docker-compose-v2
  docker-doc
  docker-buildx
  podman-docker
  containerd
  runc
)

for pkg in "${conflicting_packages[@]}"; do
  if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null |
    grep -q "ok installed"; then
    sudo apt remove -y "$pkg"
  fi
done

# --------------------------------------------------
# Docker official repository
# --------------------------------------------------

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL \
  https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# --------------------------------------------------
# Docker Engine
# --------------------------------------------------

sudo apt update

sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# --------------------------------------------------
# Service
# --------------------------------------------------

sudo systemctl enable --now docker

# --------------------------------------------------
# Allow current user to use Docker without sudo
# --------------------------------------------------

if ! id -nG "$USER" | grep -qw docker; then
  sudo usermod -aG docker "$USER"

  echo
  echo "Added $USER to docker group."
  echo "Log out and log back in before using docker without sudo."
fi
