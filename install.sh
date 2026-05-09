#!/bin/bash

set -e

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# ── Detect OS ───────────────────────────────────────────────────
. "$DOTFILES_ROOT/utils/detect_os.sh"


OS=$(detect_os)
echo "[*] Detected OS: $OS"
echo ""

# ── Route to correct installer ──────────────────────────────────
case "$OS" in
    arch)
        echo "[*] Routing to Arch Linux installer..."
        bash "$(dirname "$0")/scripts/install/install_arch.sh" "$@"
        ;;
    ubuntu|debian|linuxmint|pop)
        echo "[*] Routing to Ubuntu/Debian installer..."
        bash "$(dirname "$0")/scripts/install/install_ubuntu.sh" "$@"
        ;;
    wsl2)
        echo "[*] Routing to WSL2 installer..."
        bash "$(dirname "$0")/scripts/install/install_wsl2.sh" "$@"
        ;;
    *)
        echo "[!] Unsupported OS: $OS"
        echo "    Supported: arch, ubuntu, debian, linuxmint, pop"
        exit 1
        ;;
esac

echo ""
echo "[✓] Installation complete."
