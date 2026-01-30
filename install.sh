#!/bin/bash

set -e

echo "[*] Installing base tools..."

# List of required apt packages
APT_PACKAGES=(
  git curl zsh tmux build-essential xclip xsel wl-clipboard xxd
)

# Install missing apt packages
for pkg in "${APT_PACKAGES[@]}"; do
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "Installing $pkg..."
    sudo apt install -y "$pkg"
  else
    echo "[✓] $pkg already installed."
  fi
done

echo "[*] Running font installer..."
bash ./scripts/install_firacode_nerd_font.sh

echo "[*] Running Docker installer..."
bash ./scripts/install_docker.sh

echo "Running Neovim installer..."
bash ./scripts/install_nvim.sh

echo "[✓] Setup complete."
