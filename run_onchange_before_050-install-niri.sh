#!/usr/bin/env bash

set -euo pipefail

sudo apt update
sudo apt install -y software-properties-common

sudo add-apt-repository -y ppa:avengemedia/danklinux

sudo apt update
sudo apt install -y niri
