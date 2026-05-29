#!/bin/bash

set -e

# ── Paths ────────────────────────────────────────────────────────
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$DOTFILES_ROOT/scripts"

# ── Feature Flags ───────────────────────────────────────────────
UNINSTALL_BASE=true
UNINSTALL_NVIM=true

# ── Parse Args ──────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-base)    UNINSTALL_BASE=false; shift ;;
        --skip-nvim)    UNINSTALL_NVIM=false; shift ;;
        --only-base)    UNINSTALL_NVIM=false; shift ;;
        --only-nvim)    UNINSTALL_BASE=false; shift ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-base         Skip base tools removal"
            echo "  --skip-nvim         Skip Neovim removal"
            echo "  --only-base         Remove only base tools"
            echo "  --only-nvim         Remove only Neovim"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                  # Remove everything"
            echo "  $0 --only-nvim      # Remove only Neovim"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "[*] Starting WSL2 uninstallation with flags:"
echo "    UNINSTALL_BASE=$UNINSTALL_BASE"
echo "    UNINSTALL_NVIM=$UNINSTALL_NVIM"
echo ""

# ── Base Tools ──────────────────────────────────────────────────
if [ "$UNINSTALL_BASE" = "true" ]; then
    echo "[*] Removing base tools..."

    APT_PACKAGES=(git curl zsh tmux build-essential xxd)

    for pkg in "${APT_PACKAGES[@]}"; do
        if dpkg -s "$pkg" >/dev/null 2>&1; then
            echo "[*] Removing $pkg..."
            sudo apt-get remove --purge -y "$pkg"
        else
            echo "[✓] $pkg not installed. Skipping."
        fi
    done

    sudo apt-get autoremove -y

    # ── win32yank ────────────────────────────────────────────────
    WIN32YANK_BIN="$HOME/.local/bin/win32yank"
    if [ -f "${WIN32YANK_BIN}.exe" ] || [ -f "$WIN32YANK_BIN" ]; then
        echo "[*] Removing win32yank..."
        rm -f "${WIN32YANK_BIN}.exe" "$WIN32YANK_BIN"
    else
        echo "[✓] win32yank not found. Skipping."
    fi

    # ── nvm + node ───────────────────────────────────────────────
    NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        echo "[*] Removing nvm and all managed Node versions..."
        rm -rf "$NVM_DIR"
        # Remove the nvm loader lines from shell rc files
        for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
            if [ -f "$rc" ]; then
                # Strip the three-line nvm init block inserted by the nvm installer
                sed -i '/NVM_DIR/d' "$rc"
                sed -i '/nvm\.sh/d' "$rc"
                sed -i '/bash_completion.*nvm/d' "$rc"
                echo "[✓] Cleaned nvm entries from $rc"
            fi
        done
    else
        echo "[✓] nvm not found. Skipping."
    fi
else
    echo "[⊘] Skipping base tools removal"
fi

# ── Neovim ──────────────────────────────────────────────────────
if [ "$UNINSTALL_NVIM" = "true" ]; then
    echo "[*] Running Neovim uninstaller..."
    bash "$SCRIPTS_DIR/uninstall/uninstall_nvim.sh"
else
    echo "[⊘] Skipping Neovim removal"
fi

echo ""
echo "[✓] WSL2 uninstallation complete."
