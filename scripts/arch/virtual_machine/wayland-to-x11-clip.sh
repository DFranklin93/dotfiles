#!/bin/bash

# ── Wait for Wayland socket to be ready ────────────────────────
sleep 5

# ── Dynamically detect Wayland and X11 display sockets ─────────
detect_displays() {
    for sock in /run/user/$(id -u)/wayland-*; do
        if [ -S "$sock" ]; then
            export WAYLAND_DISPLAY=$(basename "$sock")
        fi
    done

    for x in /tmp/.X11-unix/X*; do
        num="${x##*/X}"
        if [ -S "$x" ] && echo "$num" | grep -qE '^[0-9]+$'; then
            export DISPLAY=":$num"
        fi
    done
}

detect_displays
echo "Using WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
echo "Using DISPLAY=$DISPLAY"

DETECTED_DISPLAY=$DISPLAY
DETECTED_WAYLAND=$WAYLAND_DISPLAY

# ── Wayland → X11 (guest to host) ──────────────────────────────
wl-paste --watch bash -c "
    export DISPLAY=$DETECTED_DISPLAY
    export WAYLAND_DISPLAY=$DETECTED_WAYLAND
    sleep 0.1
    CONTENT=\$(wl-paste --no-newline 2>/dev/null)
    if [ -n \"\$CONTENT\" ]; then
        echo -n \"\$CONTENT\" | DISPLAY=$DETECTED_DISPLAY xclip -selection clipboard -i
    fi
" &

# ── X11 → Wayland (host to guest) ──────────────────────────────
PREV_X11=""
while true; do
    CURRENT_X11=$(DISPLAY=$DETECTED_DISPLAY xclip -selection clipboard -o 2>/dev/null)
    if [ -n "$CURRENT_X11" ] && [ "$CURRENT_X11" != "$PREV_X11" ]; then
        echo -n "$CURRENT_X11" | wl-copy
        PREV_X11="$CURRENT_X11"
    fi
    sleep 0.5
done
