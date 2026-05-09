#!/bin/bash

set -e

# Get the dotfiles repo root (parent of scripts/install directory)
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# ── Detect OS ───────────────────────────────────────────────────
. "dotfiles/utils/detect_os.sh"

OS=$(detect_os)

echo "[*] Installing Neovim..."

# ── Install Neovim ──────────────────────────────────────────────
if ! command -v nvim >/dev/null 2>&1; then
    case "$OS" in
        arch)
            echo "[*] Installing Neovim via pacman..."
            sudo pacman -S --noconfirm --needed neovim
            ;;
        ubuntu|debian|linuxmint|pop)
            if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
                echo "[*] Running in container, installing Neovim via apt..."
                sudo apt-get update
                sudo apt-get install -y neovim
            else
                echo "[*] Installing Neovim via snap..."
                sudo snap install nvim --classic
            fi
            ;;
        *)
            echo "[!] Unsupported OS: $OS"
            exit 1
            ;;
    esac
else
    echo "[✓] Neovim already installed."
fi

# ── Install Dependencies ────────────────────────────────────────
echo "[*] Installing Neovim dependencies..."

case "$OS" in
    arch)
        for pkg in nodejs npm python; do
            if ! pacman -Qi "$pkg" &>/dev/null; then
                echo "Installing $pkg..."
                sudo pacman -S --noconfirm --needed "$pkg"
            else
                echo "[✓] $pkg already installed."
            fi
        done
        ;;
    ubuntu|debian|linuxmint|pop)
        for pkg in nodejs npm python3; do
            if ! dpkg -s "$pkg" >/dev/null 2>&1; then
                echo "Installing $pkg..."
                sudo apt-get install -y "$pkg"
            else
                echo "[✓] $pkg already installed."
            fi
        done
        ;;
esac

# ── Symlink Neovim Config ───────────────────────────────────────
echo "[*] Setting up Neovim config..."

mkdir -p ~/.config

if [ -L ~/.config/nvim ] && [ "$(readlink ~/.config/nvim)" = "$DOTFILES_ROOT/.config/nvim" ]; then
    echo "[✓] Neovim config symlink already exists."
else
    echo "[*] Linking Neovim config..."
    ln -sf "$DOTFILES_ROOT/.config/nvim" ~/.config/nvim
fi

# ── Bootstrap lazy.nvim ─────────────────────────────────────────
LAZY_PATH="$HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim"
if [ -d "$LAZY_PATH" ]; then
    echo "[✓] lazy.nvim already installed."
else
    echo "[*] Installing lazy.nvim plugin manager..."
    git clone https://github.com/folke/lazy.nvim.git "$LAZY_PATH"
fi

# ── Sync Plugins ────────────────────────────────────────────────
# Sync plugins and build treesitter parsers
echo "[*] Syncing Neovim plugins..."
nvim --headless "+Lazy sync" +qa

echo "[*] Building Treesitter parsers..."
nvim --headless "+TSUpdate" +qa
echo "[✓] Neovim setup complete."
