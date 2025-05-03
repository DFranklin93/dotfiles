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

## Reset terminal font if possible
#TERM_EMULATOR=$(ps -o comm= -p "$(ps -o ppid= -p $$)" | tr '[:upper:]' '[:lower:]')
#
#case "$TERM_EMULATOR" in
#  gnome-terminal|gnome-terminal-*)
#    PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
#    echo "[*] Resetting GNOME Terminal font to system default..."
#    gsettings reset \
#      "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/" \
#      font
#    ;;
#  *)
#    echo "[!] Could not auto-detect a supported terminal emulator."
#    echo "    You may need to reset the terminal font manually."
#    ;;
#esac

echo "[✓] Uninstall of $FONT_NAME complete."

