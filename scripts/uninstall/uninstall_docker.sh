#!/bin/bash

set -e

# ── Detect OS ───────────────────────────────────────────────────
. "dotfiles/utils/detect_os.sh"

OS=$(detect_os)

# ── Skip if running in a VM ─────────────────────────────────────
if systemd-detect-virt --quiet; then
    echo "[⊘] Running in a VM ($(systemd-detect-virt)), Docker was not installed. Skipping."
    exit 0
fi

# ── Skip if running in a container ──────────────────────────────
if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    echo "[⊘] Running inside a container, skipping Docker uninstallation"
    exit 0
fi

# ── Check if Docker is installed ────────────────────────────────
if ! command -v docker >/dev/null 2>&1; then
    echo "[✓] Docker is not installed. Nothing to uninstall."
    exit 0
fi

echo "[!] WARNING: This will remove Docker and ALL containers, images, volumes, and networks."
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "[✓] Docker uninstallation cancelled."
    exit 0
fi

echo "[*] Uninstalling Docker..."

# ── Stop and Remove All Containers ──────────────────────────────
if [ "$(docker ps -q 2>/dev/null)" ]; then
    echo "[*] Stopping all running containers..."
    docker stop $(docker ps -q)
else
    echo "[✓] No running containers."
fi

if [ "$(docker ps -aq 2>/dev/null)" ]; then
    echo "[*] Removing all containers..."
    docker rm $(docker ps -aq)
else
    echo "[✓] No containers to remove."
fi

# ── Remove All Images ───────────────────────────────────────────
if [ "$(docker images -q 2>/dev/null)" ]; then
    echo "[*] Removing all images..."
    docker rmi $(docker images -q) -f
else
    echo "[✓] No images to remove."
fi

# ── Remove All Volumes ──────────────────────────────────────────
if [ "$(docker volume ls -q 2>/dev/null)" ]; then
    echo "[*] Removing all volumes..."
    docker volume rm $(docker volume ls -q)
else
    echo "[✓] No volumes to remove."
fi

# ── Remove Custom Networks ───────────────────────────────────────
if [ "$(docker network ls -q -f type=custom 2>/dev/null)" ]; then
    echo "[*] Removing custom networks..."
    docker network rm $(docker network ls -q -f type=custom)
else
    echo "[✓] No custom networks to remove."
fi

# ── Remove Docker Group ─────────────────────────────────────────
if getent group docker >/dev/null 2>&1; then
    echo "[*] Removing docker group..."
    sudo groupdel docker
else
    echo "[✓] Docker group not found."
fi

# ── Remove Docker Data Directories ──────────────────────────────
for dir in /var/lib/docker /var/lib/containerd; do
    if [ -d "$dir" ]; then
        echo "[*] Removing $dir..."
        sudo rm -rf "$dir"
    else
        echo "[✓] $dir not found."
    fi
done

# ── OS-Specific Package Removal ─────────────────────────────────
case "$OS" in
    arch)
        echo "[*] Removing Docker packages via pacman..."
        sudo systemctl disable --now docker 2>/dev/null || true

        DOCKER_PACKAGES=(
            docker
            docker-compose
        )
        for pkg in "${DOCKER_PACKAGES[@]}"; do
            if pacman -Qi "$pkg" &>/dev/null; then
                echo "Removing $pkg..."
                sudo pacman -Rns --noconfirm "$pkg"
            else
                echo "[✓] $pkg not installed."
            fi
        done

        # Clean orphans
        ORPHANS=$(pacman -Qdtq 2>/dev/null)
        if [ -n "$ORPHANS" ]; then
            echo "[*] Removing orphaned packages..."
            sudo pacman -Rns --noconfirm $ORPHANS
        else
            echo "[✓] No orphaned packages."
        fi
        ;;

    ubuntu|debian|linuxmint|pop)
        echo "[*] Removing Docker packages via apt..."
        sudo apt remove --purge -y \
            docker-ce \
            docker-ce-cli \
            containerd.io \
            docker-buildx-plugin \
            docker-compose-plugin

        # Remove Docker repository
        if [ -f /etc/apt/sources.list.d/docker.list ]; then
            echo "[*] Removing Docker repository..."
            sudo rm /etc/apt/sources.list.d/docker.list
        else
            echo "[✓] Docker repository not found."
        fi

        # Remove Docker GPG key
        if [ -f /etc/apt/keyrings/docker.gpg ]; then
            echo "[*] Removing Docker GPG key..."
            sudo rm /etc/apt/keyrings/docker.gpg
        else
            echo "[✓] Docker GPG key not found."
        fi

        sudo apt autoremove -y
        sudo apt clean
        ;;

    *)
        echo "[!] Unsupported OS: $OS"
        exit 1
        ;;
esac

echo ""
echo "[✓] Docker uninstallation complete!"
