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

echo "[✓] FiraCode Nerd Font installed successfully."
