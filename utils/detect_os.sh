#!/bin/bash

# detect_os.sh
# Returns a normalized OS identifier string.
# WSL2 is detected first (before /etc/os-release) since the underlying
# distro ID is still ubuntu/debian/etc — callers that need to distinguish
# WSL2 from bare-metal Ubuntu must check for "wsl2" explicitly.
#
# Possible return values:
#   wsl2 | arch | ubuntu | debian | linuxmint | pop | fedora | unknown

detect_os() {
    # ── WSL2 ─────────────────────────────────────────────────────
    # /proc/version contains "microsoft" on WSL1 and WSL2; the presence
    # of WSL_DISTRO_NAME or WSL_INTEROP narrows it to WSL2.
    if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl2"
        return
    fi

    # ── /etc/os-release fallback ─────────────────────────────────
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "${ID,,}"   # lowercase, e.g. "ubuntu", "arch", "fedora"
        return
    fi

    echo "unknown"
}
