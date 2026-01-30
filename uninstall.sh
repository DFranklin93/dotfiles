#!/bin/bash

set -e

echo "[*] Reverting Neovim configuration..."

# Remove Neovim config symlink if it points to the dotfiles repo
if [ -L ~/.config/nvim ]; then
  TARGET=$(readlink ~/.config/nvim)
  if [ "$TARGET" = "$HOME/dotfiles/.config/nvim" ]; then
    echo "Removing symlink ~/.config/nvim"
    rm ~/.config/nvim
  else
    echo "[!] ~/.config/nvim is a symlink, but not managed by this setup. Skipping."
  fi
elif [ -d ~/.config/nvim ]; then
  echo "[!] ~/.config/nvim is a directory, not a symlink. Skipping removal to avoid data loss."
else
  echo "[✓] ~/.config/nvim not found. Nothing to remove."
fi

# Remove lazy.nvim plugin manager
LAZY_PATH="$HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim"
if [ -d "$LAZY_PATH" ]; then
  echo "Removing lazy.nvim plugin manager..."
  rm -rf "$LAZY_PATH"
else
  echo "[✓] lazy.nvim not found."
fi

# Cleanup dotfiles repo
if [ -d "$HOME/dotfiles" ]; then
  echo "Removing cloned dotfiles repo..."
  rm -rf "$HOME/dotfiles"
else
  echo "[✓] dotfiles repo not found. Skipping."
fi

# Uninstall Neovim snap if installed
if snap list 2>/dev/null | grep -q nvim; then
  echo "Removing Neovim via Snap..."
  sudo snap remove nvim
else
  echo "[✓] Neovim Snap not installed."
fi

# Remove apt packages if they are present
APT_PACKAGES=(
  git curl zsh tmux build-essential xclip xsel wl-clipboard xxd
)

echo "[*] Removing installed apt packages..."
for pkg in "${APT_PACKAGES[@]}"; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "Removing $pkg..."
    sudo apt remove --purge -y "$pkg"
  else
    echo "[✓] $pkg not installed."
  fi
done

sudo apt autoremove -y
sudo apt clean

# Uninstall FiraCode Nerd Font
FONT_DIR="$HOME/.local/share/fonts/FiraCode"
if [ -d "$FONT_DIR" ]; then
  echo "[*] Removing FiraCode Nerd Font..."
  rm -rf "$FONT_DIR"
else
  echo "[✓] FiraCode Nerd Font directory not found."
fi

echo "[*] Refreshing font cache..."
fc-cache -fv

# Uninstall Docker
echo "[*] Running Docker uninstaller..."
bash ./scripts/uninstall_docker.sh

echo "[✓] Uninstallation complete."
