#!/bin/bash

set -e

# Get the dotfiles repo root (parent of scripts directory)
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[*] Installing Neovim..."

# Install Neovim 
if ! command -v nvim >/dev/null 2>&1; then
  if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    echo "[*] Running in container, installing Neovim via apt..."
    sudo apt-get update
    sudo apt-get install -y neovim
  else
    echo "[*] Installing Neovim via snap..."
    sudo snap install nvim --classic
  fi
else
  echo "[✓] Neovim already installed."
fi

# Set up Neovim config
echo "[*] Setting up Neovim config..."

mkdir -p ~/.config

if [ -L ~/.config/nvim ] && [ "$(readlink ~/.config/nvim)" = "$DOTFILES_ROOT/.config/nvim" ]; then
  echo "[✓] Neovim config symlink already exists."
else
  echo "[*] Linking Neovim config..."
  ln -sf "$DOTFILES_ROOT/.config/nvim" ~/.config/nvim
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

echo "[✓] Neovim setup complete."
