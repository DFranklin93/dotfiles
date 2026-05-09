#!/bin/bash

set -e

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# ── Detect OS ───────────────────────────────────────────────────
. "$DOTFILES_ROOT/utils/detect_os.sh"

OS=$(detect_os)
echo "[*] Detected OS: $OS"
echo ""

# ── Route to correct uninstaller ────────────────────────────────
case "$OS" in
    arch)
        echo "[*] Routing to Arch Linux uninstaller..."
        bash "$(dirname "$0")/scripts/uninstall/uninstall_arch.sh" "$@"
        ;;
    ubuntu|debian|linuxmint|pop)
        echo "[*] Routing to Ubuntu/Debian uninstaller..."
        bash "$(dirname "$0")/scripts/uninstall/uninstall_ubuntu.sh" "$@"
        ;;
    wsl2)
        echo "[*] Routing to WSL2 uninstaller..."
        bash "$(dirname "$0")/scripts/uninstall/uninstall_wsl2.sh" "$@"
        ;;
    *)
        echo "[!] Unsupported OS: $OS"
        echo "    Supported: arch, ubuntu, debian, linuxmint, pop, wsl2"
        exit 1
        ;;
esac

echo ""
echo "[✓] Uninstallation complete."
