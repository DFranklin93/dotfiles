#!/bin/bash

set -e

echo "[!] WARNING: This will remove Docker and ALL containers, images, volumes, and networks."
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "[✓] Docker uninstallation cancelled."
  exit 0
fi

echo "[*] Uninstalling Docker..."

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
  echo "[✓] Docker is not installed. Nothing to uninstall."
  return 0 2>/dev/null || exit 0
fi

# Stop all running containers
if [ "$(docker ps -q)" ]; then
  echo "[*] Stopping all running containers..."
  docker stop $(docker ps -q)
fi

# Remove all containers
if [ "$(docker ps -aq)" ]; then
  echo "[*] Removing all containers..."
  docker rm $(docker ps -aq)
fi

# Remove all images
if [ "$(docker images -q)" ]; then
  echo "[*] Removing all images..."
  docker rmi $(docker images -q) -f
fi

# Remove all volumes
if [ "$(docker volume ls -q)" ]; then
  echo "[*] Removing all volumes..."
  docker volume rm $(docker volume ls -q)
fi

# Remove all networks (except default ones)
if [ "$(docker network ls -q -f type=custom)" ]; then
  echo "[*] Removing custom networks..."
  docker network rm $(docker network ls -q -f type=custom)
fi

# Uninstall Docker packages
echo "[*] Removing Docker packages..."
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
fi

# Remove Docker GPG key
if [ -f /etc/apt/keyrings/docker.gpg ]; then
  echo "[*] Removing Docker GPG key..."
  sudo rm /etc/apt/keyrings/docker.gpg
fi

# Remove Docker group
if getent group docker >/dev/null 2>&1; then
  echo "[*] Removing docker group..."
  sudo groupdel docker
fi

# Remove Docker data directories
if [ -d /var/lib/docker ]; then
  echo "[*] Removing Docker data directory..."
  sudo rm -rf /var/lib/docker
fi

if [ -d /var/lib/containerd ]; then
  echo "[*] Removing containerd data directory..."
  sudo rm -rf /var/lib/containerd
fi

# Clean up unused packages
echo "[*] Cleaning up unused packages..."
sudo apt autoremove -y
sudo apt clean

echo "[✓] Docker uninstallation complete!"
