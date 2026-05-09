#!/bin/bash

set -e

# ── Paths ────────────────────────────────────────────────────────
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$DOTFILES_ROOT/scripts"

# ── Feature Flags ───────────────────────────────────────────────
UNINSTALL_BASE=true
UNINSTALL_FONTS=true
UNINSTALL_DOCKER=true
UNINSTALL_NVIM=true

# ── Parse Args ──────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-base)        UNINSTALL_BASE=false;   shift ;;
        --skip-fonts)       UNINSTALL_FONTS=false;  shift ;;
        --skip-docker)      UNINSTALL_DOCKER=false; shift ;;
        --skip-nvim)        UNINSTALL_NVIM=false;   shift ;;
        --only-base)
            UNINSTALL_FONTS=false; UNINSTALL_DOCKER=false
            UNINSTALL_NVIM=false
            shift ;;
        --only-fonts)
            UNINSTALL_BASE=false; UNINSTALL_DOCKER=false
            UNINSTALL_NVIM=false
            shift ;;
        --only-docker)
            UNINSTALL_BASE=false; UNINSTALL_FONTS=false
            UNINSTALL_NVIM=false
            shift ;;
        --only-nvim)
            UNINSTALL_BASE=false; UNINSTALL_FONTS=false
            UNINSTALL_DOCKER=false
            shift ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-base         Skip base tools removal"
            echo "  --skip-fonts        Skip font removal"
            echo "  --skip-docker       Skip Docker removal"
            echo "  --skip-nvim         Skip Neovim removal"
            echo "  --only-base         Remove only base tools"
            echo "  --only-fonts        Remove only fonts"
            echo "  --only-docker       Remove only Docker"
            echo "  --only-nvim         Remove only Neovim"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                          # Remove everything"
            echo "  $0 --skip-docker            # Remove everything except Docker"
            echo "  $0 --only-nvim              # Remove only Neovim"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "[*] Starting Ubuntu uninstallation with flags:"
echo "    UNINSTALL_BASE=$UNINSTALL_BASE"
echo "    UNINSTALL_FONTS=$UNINSTALL_FONTS"
echo "    UNINSTALL_DOCKER=$UNINSTALL_DOCKER"
echo "    UNINSTALL_NVIM=$UNINSTALL_NVIM"
echo ""

# ── Base Tools ──────────────────────────────────────────────────
if [ "$UNINSTALL_BASE" = "true" ]; then
    echo "[*] Removing base tools..."

    read -p "[?] Remove base tools? This may affect other applications. (y/N) " REMOVE_BASE
    if [ "$REMOVE_BASE" = "y" ]; then
        APT_PACKAGES=(
            git curl zsh tmux
            build-essential
            xclip xsel
            wl-clipboard xxd
        )
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
    else
        echo "[⊘] Skipping base tools removal"
    fi
else
    echo "[⊘] Skipping base tools removal"
fi

# ── Fonts ───────────────────────────────────────────────────────
if [ "$UNINSTALL_FONTS" = "true" ]; then
    echo "[*] Running font uninstaller..."
    bash "$SCRIPTS_DIR/uninstall/uninstall_firacode_nerd_font.sh"
else
    echo "[⊘] Skipping font removal"
fi

# ── Docker ──────────────────────────────────────────────────────
if [ "$UNINSTALL_DOCKER" = "true" ]; then
    echo "[*] Running Docker uninstaller..."
    bash "$SCRIPTS_DIR/uninstall/uninstall_docker.sh"
else
    echo "[⊘] Skipping Docker removal"
fi

# ── Neovim ──────────────────────────────────────────────────────
if [ "$UNINSTALL_NVIM" = "true" ]; then
    echo "[*] Running Neovim uninstaller..."
    bash "$SCRIPTS_DIR/uninstall/uninstall_nvim.sh"
else
    echo "[⊘] Skipping Neovim removal"
fi

echo ""
echo "[✓] Ubuntu uninstallation complete."
