#!/usr/bin/env bash

set -euo pipefail

sudo apt update
sudo apt install -y software-properties-common

sudo add-apt-repository -y ppa:obsproject/obs-studio

sudo apt update
sudo apt install -y obs-studio

echo "OBS Studio installation completed."
