#!/usr/bin/env bash

set -e

FONT_NAME="FiraCode Nerd Font Mono"
FONT_FAMILY_DIR="$HOME/.local/share/fonts/FiraCode"
FONT_CACHE_CMD="fc-cache -fv"
FONT_CHECK_CMD="fc-list | grep -i \"$FONT_NAME\""

echo "[*] Checking if $FONT_NAME is already installed..."

# Check if font is already available
if eval "$FONT_CHECK_CMD" > /dev/null; then
  echo "[✓] $FONT_NAME already installed. Skipping download."
else
  echo "[*] Installing $FONT_NAME..."

  # Create fonts directory
  mkdir -p "$FONT_FAMILY_DIR"
  cd "$FONT_FAMILY_DIR"

  # Download and extract
  ZIP="FiraCode.zip"
  curl --fail --location --show-error \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${ZIP}" \
    --output "$ZIP"

  unzip -o -q "$ZIP"
  rm "$ZIP"

  # Refresh font cache
  echo "[*] Refreshing font cache..."
  eval "$FONT_CACHE_CMD"
fi

## Detect terminal emulator
#echo "[*] Detecting terminal emulator..."
#
## Function to set font for GNOME Terminal
#set_gnome_terminal_font() {
#  PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
#  FONT_STRING="${FONT_NAME} 12"
#
#  echo "[*] Setting font in GNOME Terminal to '${FONT_STRING}'..."
#  gsettings set \
#    "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/" \
#    font "$FONT_STRING"
#  echo "[✓] GNOME Terminal font set successfully."
#}
#
#TERM_EMULATOR=$(ps -o comm= -p "$(ps -o ppid= -p $$)" | tr '[:upper:]' '[:lower:]')
#
#case "$TERM_EMULATOR" in
#  gnome-terminal|gnome-terminal-*)
#    set_gnome_terminal_font
#    ;;
#  *)
#    echo "[!] Could not auto-detect a supported terminal emulator."
#    echo "    Please set the terminal font manually to: $FONT_NAME"
#    ;;
#esac

echo "[✓] FiraCode Nerd Font installed successfully."
