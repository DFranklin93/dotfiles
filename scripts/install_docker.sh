#!/bin/bash

set -e

echo "[*] Installing Docker..."

# Check if Docker is already installed
if command -v docker >/dev/null 2>&1; then
  echo "[✓] Docker already installed ($(docker --version))"
  
  # Check if user is in docker group
  if groups $USER | grep -q '\bdocker\b'; then
    echo "[✓] User already in docker group"
    return 0 2>/dev/null || exit 0
  else
    echo "[*] Adding user to docker group..."
    sudo usermod -aG docker $USER
    echo "[!] You'll need to log out and back in for group changes to take effect"
    echo "    Or run: newgrp docker"
    return 0 2>/dev/null || exit 0
  fi
fi

# Install prerequisites
echo "[*] Installing prerequisites..."
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
echo "[*] Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the repository
echo "[*] Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
echo "[*] Installing Docker Engine..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
echo "[*] Adding user to docker group..."
sudo usermod -aG docker $USER

# Verify installation
echo "[*] Verifying Docker installation..."
sudo docker run hello-world

echo "[✓] Docker installation complete!"
echo "[!] You'll need to log out and back in for group changes to take effect"
echo "    Or run: newgrp docker"
