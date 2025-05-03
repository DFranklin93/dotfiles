#!/usr/bin/env bash

set -e

FONT_NAME="FiraCode Nerd Font Mono"
FONT_FAMILY_DIR="$HOME/.local/share/fonts/FiraCode"

echo "[*] Removing $FONT_NAME..."

if [ -d "$FONT_FAMILY_DIR" ]; then
  rm -rf "$FONT_FAMILY_DIR"
  echo "[*] Removed font files from $FONT_FAMILY_DIR"
else
  echo "[!] Font directory not found: $FONT_FAMILY_DIR"
fi

# Refresh font cache
fc-cache -fv

echo "[✓] Uninstall of $FONT_NAME complete."
