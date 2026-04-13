#!/usr/bin/env bash

set -e

FONT_NAME="FiraCode Nerd Font Mono"
FONT_FAMILY_DIR="$HOME/.local/share/fonts/FiraCode"
FONT_CACHE_CMD="fc-cache -fv"
FONT_CHECK_CMD="fc-list | grep -i \"$FONT_NAME\""

# ── Detect OS ───────────────────────────────────────────────────
. "dotfiles/utils/detect_os.sh"

OS=$(detect_os)

# ── Install Dependencies ────────────────────────────────────────
install_dep() {
    local cmd="$1"
    local pkg="$2"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[*] Installing $pkg..."
        case "$OS" in
            arch)
                sudo pacman -S --noconfirm --needed "$pkg"
                ;;
            ubuntu|debian|linuxmint|pop)
                sudo apt-get install -y "$pkg"
                ;;
            *)
                echo "[!] Cannot install $pkg — unsupported OS: $OS"
                exit 1
                ;;
        esac
    else
        echo "[✓] $cmd already available."
    fi
}

install_dep curl curl
install_dep unzip unzip
install_dep fc-cache fontconfig

# ── Install Font ────────────────────────────────────────────────
echo "[*] Checking if $FONT_NAME is already installed..."

if eval "$FONT_CHECK_CMD" > /dev/null; then
    echo "[✓] $FONT_NAME already installed. Skipping download."
else
    echo "[*] Installing $FONT_NAME..."

    mkdir -p "$FONT_FAMILY_DIR"
    cd "$FONT_FAMILY_DIR"

    ZIP="FiraCode.zip"
    curl --fail --location --show-error \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${ZIP}" \
        --output "$ZIP"

    unzip -o -q "$ZIP"
    rm "$ZIP"

    echo "[*] Refreshing font cache..."
    eval "$FONT_CACHE_CMD"
fi

echo "[✓] FiraCode Nerd Font installed successfully."
