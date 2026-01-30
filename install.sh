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

# Install Neovim via snap if not present
if ! command -v nvim >/dev/null 2>&1; then
  echo "[*] Installing Neovim via snap..."
  sudo snap install nvim --classic
else
  echo "[✓] Neovim already installed."
fi

# Set up Neovim config
echo "[*] Setting up Neovim config..."

mkdir -p ~/.config

if [ -L ~/.config/nvim ] && [ "$(readlink ~/.config/nvim)" = "$PWD/.config/nvim" ]; then
  echo "[✓] Neovim config symlink already exists."
else
  echo "[*] Linking Neovim config..."
  ln -sf "$PWD/.config/nvim" ~/.config/nvim
fi

# Bootstrap lazy.nvim plugin manager
LAZY_PATH="$HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim"
if [ -d "$LAZY_PATH" ]; then
  echo "[✓] lazy.nvim already installed."
else
  echo "[*] Installing lazy.nvim plugin manager..."
  git clone https://github.com/folke/lazy.nvim.git "$LAZY_PATH"
fi

# Sync plugins
echo "[*] Syncing Neovim plugins..."
nvim --headless "+Lazy sync" +qa

echo "[✓] Setup complete."
