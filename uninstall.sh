#!/bin/bash

set -e

# ── Detect OS ───────────────────────────────────────────────────
. "dotfiles/utils/detect_os.sh"

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
    *)
        echo "[!] Unsupported OS: $OS"
        echo "    Supported: arch, ubuntu, debian, linuxmint, pop"
        exit 1
        ;;
esac

echo ""
echo "[✓] Uninstallation complete."
