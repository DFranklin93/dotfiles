#!/bin/bash

set -e

# ── Paths ────────────────────────────────────────────────────────
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$DOTFILES_ROOT/scripts"

# ── Feature Flags ───────────────────────────────────────────────
INSTALL_BASE=true
INSTALL_NVIM=true

# ── Parse Args ──────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-base)    INSTALL_BASE=false; shift ;;
        --skip-nvim)    INSTALL_NVIM=false; shift ;;
        --only-base)    INSTALL_NVIM=false; shift ;;
        --only-nvim)    INSTALL_BASE=false; shift ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-base         Skip base tools installation"
            echo "  --skip-nvim         Skip Neovim installation"
            echo "  --only-base         Install only base tools"
            echo "  --only-nvim         Install only Neovim"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Notes:"
            echo "  Fonts  — install Nerd Fonts on the Windows host (e.g. via"
            echo "           Scoop: 'scoop install nerd-fonts/FiraCode-NF')."
            echo "  Docker — use Docker Desktop with WSL2 backend enabled."
            echo "           (Settings > Resources > WSL Integration)"
            echo "  Clipboard — win32yank is installed by the base step and"
            echo "           wired up via \$DOTFILES_ROOT/.config/nvim."
            echo ""
            echo "Examples:"
            echo "  $0                  # Install everything"
            echo "  $0 --only-nvim      # Install only Neovim"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "[*] Starting WSL2 installation with flags:"
echo "    INSTALL_BASE=$INSTALL_BASE"
echo "    INSTALL_NVIM=$INSTALL_NVIM"
echo ""
echo "[i] Skipped on WSL2 (handled on the Windows host):"
echo "    fonts  — install via Scoop/winget/manually in Windows"
echo "    docker — use Docker Desktop WSL2 backend"
echo ""

# ── Base Tools ──────────────────────────────────────────────────
if [ "$INSTALL_BASE" = "true" ]; then
    echo "[*] Installing base tools..."

    APT_PACKAGES=(
        git curl zsh tmux
        build-essential
        xxd
    )

    sudo apt-get update -qq

    for pkg in "${APT_PACKAGES[@]}"; do
        # skip comment lines that bash includes from the array literal
        [[ "$pkg" == \#* ]] && continue
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            echo "Installing $pkg..."
            sudo apt-get install -y "$pkg"
        else
            echo "[✓] $pkg already installed."
        fi
    done
else
    echo "[⊘] Skipping base tools installation"
fi

# ── Neovim ──────────────────────────────────────────────────────
if [ "$INSTALL_NVIM" = "true" ]; then
    echo "[*] Running Neovim installer..."
    bash "$SCRIPTS_DIR/install/install_nvim.sh"
else
    echo "[⊘] Skipping Neovim installation"
fi

echo ""
echo "[✓] WSL2 installation complete."
