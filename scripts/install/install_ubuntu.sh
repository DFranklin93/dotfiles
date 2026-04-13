#!/bin/bash

set -e

# ── Paths ────────────────────────────────────────────────────────
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$DOTFILES_ROOT/scripts"

# ── Feature Flags ───────────────────────────────────────────────
INSTALL_BASE=true
INSTALL_FONTS=true
INSTALL_DOCKER=true
INSTALL_NVIM=true

# ── Parse Args ──────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-base)        INSTALL_BASE=false;   shift ;;
        --skip-fonts)       INSTALL_FONTS=false;  shift ;;
        --skip-docker)      INSTALL_DOCKER=false; shift ;;
        --skip-nvim)        INSTALL_NVIM=false;   shift ;;
        --only-base)
            INSTALL_FONTS=false; INSTALL_DOCKER=false
            INSTALL_NVIM=false
            shift ;;
        --only-fonts)
            INSTALL_BASE=false; INSTALL_DOCKER=false
            INSTALL_NVIM=false
            shift ;;
        --only-docker)
            INSTALL_BASE=false; INSTALL_FONTS=false
            INSTALL_NVIM=false
            shift ;;
        --only-nvim)
            INSTALL_BASE=false; INSTALL_FONTS=false
            INSTALL_DOCKER=false
            shift ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-base         Skip base tools installation"
            echo "  --skip-fonts        Skip font installation"
            echo "  --skip-docker       Skip Docker installation"
            echo "  --skip-nvim         Skip Neovim installation"
            echo "  --only-base         Install only base tools"
            echo "  --only-fonts        Install only fonts"
            echo "  --only-docker       Install only Docker"
            echo "  --only-nvim         Install only Neovim"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                          # Install everything"
            echo "  $0 --skip-docker            # Install everything except Docker"
            echo "  $0 --only-nvim              # Install only Neovim"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "[*] Starting Ubuntu installation with flags:"
echo "    INSTALL_BASE=$INSTALL_BASE"
echo "    INSTALL_FONTS=$INSTALL_FONTS"
echo "    INSTALL_DOCKER=$INSTALL_DOCKER"
echo "    INSTALL_NVIM=$INSTALL_NVIM"
echo ""

# ── Base Tools ──────────────────────────────────────────────────
if [ "$INSTALL_BASE" = "true" ]; then
    echo "[*] Installing base tools..."
    APT_PACKAGES=(
        git curl zsh tmux
        build-essential
        xclip xsel
        wl-clipboard xxd
    )
    for pkg in "${APT_PACKAGES[@]}"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            echo "Installing $pkg..."
            sudo apt install -y "$pkg"
        else
            echo "[✓] $pkg already installed."
        fi
    done
else
    echo "[⊘] Skipping base tools installation"
fi

# ── Fonts ───────────────────────────────────────────────────────
if [ "$INSTALL_FONTS" = "true" ]; then
    echo "[*] Running font installer..."
    bash "$SCRIPTS_DIR/install/install_firacode_nerd_font.sh"
else
    echo "[⊘] Skipping font installation"
fi

# ── Docker ──────────────────────────────────────────────────────
if [ "$INSTALL_DOCKER" = "true" ]; then
    echo "[*] Running Docker installer..."
    bash "$SCRIPTS_DIR/install/install_docker.sh"
else
    echo "[⊘] Skipping Docker installation"
fi

# ── Neovim ──────────────────────────────────────────────────────
if [ "$INSTALL_NVIM" = "true" ]; then
    echo "[*] Running Neovim installer..."
    bash "$SCRIPTS_DIR/install/install_nvim.sh"
else
    echo "[⊘] Skipping Neovim installation"
fi

echo ""
echo "[✓] Ubuntu installation complete."
