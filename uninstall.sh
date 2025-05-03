#!/bin/bash

set -e

echo "[*] Reverting Neovim configuration..."

# Remove Neovim config symlink
if [ -L ~/.config/nvim ] && [ "$(readlink ~/.config/nvim)" = "$HOME/dotfiles/.config/nvim" ]; then
  echo "Removing symlink ~/.config/nvim"
  rm ~/.config/nvim
fi

# Remove lazy.nvim plugin manager
echo "Removing lazy.nvim plugin manager..."
rm -rf ~/.local/share/nvim/site/pack/lazy/start/lazy.nvim

# Cleanup dotfiles repo
echo "Removing cloned dotfiles repo..."
rm -rf ~/dotfiles

# Uninstall Neovim snap if present
echo "[*] Checking for Neovim Snap install..."
if snap list | grep -q nvim; then
  echo "Removing Neovim via Snap..."
  sudo snap remove nvim
fi

# Remove apt packages
echo "[*] Removing installed apt packages..."
sudo apt remove --purge -y git curl zsh tmux build-essential xclip xsel wl-clipboard xxd
sudo apt autoremove -y
sudo apt clean

echo "[#] Uninstallation complete."
