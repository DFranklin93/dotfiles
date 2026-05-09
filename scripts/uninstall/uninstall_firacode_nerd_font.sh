#!/usr/bin/env bash

set -e

FONT_NAME="FiraCode Nerd Font Mono"
FONT_FAMILY_DIR="$HOME/.local/share/fonts/FiraCode"

# ── Detect OS ───────────────────────────────────────────────────
. "dotfiles/utils/detect_os.sh"

OS=$(detect_os)

# ── Ensure fc-cache is available ────────────────────────────────
if ! command -v fc-cache >/dev/null 2>&1; then
    echo "[*] Installing fontconfig..."
    case "$OS" in
        arch)
            sudo pacman -S --noconfirm --needed fontconfig
            ;;
        ubuntu|debian|linuxmint|pop)
            sudo apt-get install -y fontconfig
            ;;
        *)
            echo "[!] Cannot install fontconfig — unsupported OS: $OS"
            exit 1
            ;;
    esac
fi

echo "[*] Removing $FONT_NAME..."

# ── Remove Font Files ───────────────────────────────────────────
if [ -d "$FONT_FAMILY_DIR" ]; then
    rm -rf "$FONT_FAMILY_DIR"
    echo "[✓] Removed font files from $FONT_FAMILY_DIR"
else
    echo "[✓] Font directory not found. Nothing to remove."
fi

# ── Refresh Font Cache ──────────────────────────────────────────
echo "[*] Refreshing font cache..."
fc-cache -fv

echo "[✓] Uninstall of $FONT_NAME complete."
