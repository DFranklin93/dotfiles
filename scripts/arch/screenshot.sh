#!/bin/bash

SCREENSHOT_DIR="$HOME/Pictures/screenshots"
mkdir -p "$SCREENSHOT_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FILE="$SCREENSHOT_DIR/screenshot-$TIMESTAMP.png"

case "$1" in
    full)
        grim "$FILE"
        ACTION=$(notify-send "Screenshot" "Full screenshot saved" \
            --action="view=View" \
            --hint=string:image-path:"$FILE" \
            --expire-time=5000 \
            --wait)
        [ "$ACTION" = "view" ] && imv "$FILE" &
        ;;
    region)
        grim -g "$(slurp)" "$FILE"
        ACTION=$(notify-send "Screenshot" "Region screenshot saved" \
            --action="view=View" \
            --hint=string:image-path:"$FILE" \
            --expire-time=5000 \
            --wait)
        [ "$ACTION" = "view" ] && imv "$FILE" &
        ;;
    window)
        FOCUSED=$(hyprctl activewindow -j | python3 -c "
import sys, json
w = json.load(sys.stdin)
x, y = w['at']
width, height = w['size']
print(f'{x},{y} {width}x{height}')
")
        grim -g "$FOCUSED" "$FILE"
        ACTION=$(notify-send "Screenshot" "Window screenshot saved" \
            --action="view=View" \
            --hint=string:image-path:"$FILE" \
            --expire-time=5000 \
            --wait)
        [ "$ACTION" = "view" ] && imv "$FILE" &
        ;;
    clipboard)
        grim -g "$(slurp)" - | wl-copy
        notify-send "Screenshot" "Region copied to clipboard" \
            --expire-time=3000
        ;;
    *)
        echo "Usage: $0 {full|region|window|clipboard}"
        exit 1
        ;;
esac
