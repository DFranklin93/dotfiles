#!/bin/bash

# Wait for Wayland socket to be available
while [ -z "$WAYLAND_DISPLAY" ] || [ ! -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; do
	sleep 0.5
done

# Kill any existing swaybg
pkill swaybg

# Launch swaybg
exec swaybg -i /home/solodominus/Pictures/backgrounds/Sollee.png -m fill
