#!/usr/bin/env bash

set -euo pipefail

sudo apt update

sudo apt install -y ubuntu-desktop

sudo systemctl set-default graphical.target
sudo systemctl enable gdm3
