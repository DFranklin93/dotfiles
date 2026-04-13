#!/bin/bash

set -e

# ── Paths ───────────────────────────────────────────────────────
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# ── Detect OS ───────────────────────────────────────────────────
. "dotfiles/utils/detect_os.sh"

OS=$(detect_os)

echo "[*] Uninstalling Neovim..."

# ── Remove Neovim Config Symlink ────────────────────────────────
echo "[*] Reverting Neovim config..."
if [ -L ~/.config/nvim ]; then
    TARGET=$(readlink ~/.config/nvim)
    if [ "$TARGET" = "$DOTFILES_ROOT/.config/nvim" ]; then
        echo "Removing symlink ~/.config/nvim"
        rm ~/.config/nvim
    else
        echo "[!] ~/.config/nvim is a symlink but not managed by dotfiles. Skipping."
    fi
elif [ -d ~/.config/nvim ]; then
    echo "[!] ~/.config/nvim is a directory, not a symlink. Skipping to avoid data loss."
else
    echo "[✓] ~/.config/nvim not found. Nothing to remove."
fi

# ── Remove lazy.nvim ────────────────────────────────────────────
LAZY_PATH="$HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim"
if [ -d "$LAZY_PATH" ]; then
    echo "[*] Removing lazy.nvim plugin manager..."
    rm -rf "$LAZY_PATH"
else
    echo "[✓] lazy.nvim not found. Nothing to remove."
fi

# ── Remove Neovim Data/State ────────────────────────────────────
for dir in \
    "$HOME/.local/share/nvim" \
    "$HOME/.local/state/nvim" \
    "$HOME/.cache/nvim"; do
    if [ -d "$dir" ]; then
        echo "[*] Removing $dir..."
        rm -rf "$dir"
    else
        echo "[✓] $dir not found. Nothing to remove."
    fi
done

# ── Uninstall Neovim ────────────────────────────────────────────
case "$OS" in
    arch)
        if pacman -Qi neovim &>/dev/null; then
            echo "[*] Removing Neovim via pacman..."
            sudo pacman -Rns --noconfirm neovim
        else
            echo "[✓] Neovim not installed via pacman."
        fi
        ;;
    ubuntu|debian|linuxmint|pop)
        if snap list 2>/dev/null | grep -q nvim; then
            echo "[*] Removing Neovim via snap..."
            sudo snap remove nvim
        else
            echo "[✓] Neovim snap not installed."
        fi
        if dpkg -s neovim >/dev/null 2>&1; then
            echo "[*] Removing Neovim via apt..."
            sudo apt remove --purge -y neovim
            sudo apt autoremove -y
        else
            echo "[✓] Neovim apt package not installed."
        fi
        ;;
    *)
        echo "[!] Unsupported OS: $OS"
        exit 1
        ;;
esac

echo ""
echo "[✓] Neovim uninstallation complete."
