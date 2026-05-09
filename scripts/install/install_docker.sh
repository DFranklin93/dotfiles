#!/bin/bash

set -e

# ── Detect OS ───────────────────────────────────────────────────
. "dotfiles/utils/detect_os.sh"

OS=$(detect_os)

# ── Skip if running in a container ──────────────────────────────
if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    echo "[⊘] Running inside a container, skipping Docker installation"
    exit 0
fi

# ── Skip if running in a VM ─────────────────────────────────────
if systemd-detect-virt --quiet; then
    echo "[⊘] Running in a VM ($(systemd-detect-virt)), skipping Docker installation"
    exit 0
fi

echo "[*] Installing Docker..."

# ── Check if Docker is already installed ────────────────────────
if command -v docker >/dev/null 2>&1; then
    echo "[✓] Docker already installed ($(docker --version))"

    if groups $USER | grep -q '\bdocker\b'; then
        echo "[✓] User already in docker group"
        exit 0
    else
        echo "[*] Adding user to docker group..."
        sudo usermod -aG docker $USER
        echo "[!] Log out and back in for group changes to take effect"
        echo "    Or run: newgrp docker"
        exit 0
    fi
fi

# ── Install Docker ───────────────────────────────────────────────
case "$OS" in
    arch)
        echo "[*] Installing Docker via pacman..."
        sudo pacman -S --noconfirm --needed docker docker-compose

        echo "[*] Enabling Docker service..."
        sudo systemctl enable --now docker

        echo "[*] Adding user to docker group..."
        sudo usermod -aG docker $USER

        echo "[*] Verifying Docker installation..."
        sudo docker run hello-world
        ;;

    ubuntu|debian|linuxmint|pop)
        echo "[*] Installing prerequisites..."
        sudo apt update
        sudo apt install -y ca-certificates curl gnupg lsb-release

        echo "[*] Adding Docker GPG key..."
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        echo "[*] Setting up Docker repository..."
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        echo "[*] Installing Docker Engine..."
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        echo "[*] Adding user to docker group..."
        sudo usermod -aG docker $(whoami)

        echo "[*] Verifying Docker installation..."
        sudo docker run hello-world
        ;;

    *)
        echo "[!] Unsupported OS: $OS"
        exit 1
        ;;
esac

echo "[✓] Docker installation complete!"
echo "[!] Log out and back in for group changes to take effect"
echo "    Or run: newgrp docker"
