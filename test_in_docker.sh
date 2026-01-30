#!/bin/bash
# test_in_docker.sh

set -e

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
  echo "Error: Docker is not installed."
  echo ""
  echo "Please install Docker to use this test script."
  echo "Visit https://docs.docker.com/get-docker/ for installation instructions."
  exit 1
fi

# Check if Docker daemon is running
if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker daemon is not running."
  echo ""
  echo "Please start the Docker daemon and try again."
  echo "You may need to run: sudo systemctl start docker"
  exit 1
fi

echo "✓ Docker is available"
echo ""

echo "Building test container..."
docker build -f - -t dotfiles-test . << 'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y sudo git snapd unzip curl wget
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER testuser
WORKDIR /home/testuser
EOF

echo "Running installation in container..."
docker run -it --rm \
  -v "$PWD:/home/testuser/dotfiles:ro" \
  dotfiles-test \
  bash -c "cp -r /home/testuser/dotfiles /home/testuser/dotfiles-copy && cd /home/testuser/dotfiles-copy && bash ./install.sh --skip-fonts --skip-docker"

echo "Test complete! Container cleaned up."
