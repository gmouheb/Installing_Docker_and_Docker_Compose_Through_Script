#!/bin/bash

set -e  # Exit on any error

echo "Detecting OS..."
source /etc/os-release

# Function to install Docker on Ubuntu
install_docker_ubuntu() {
  echo "Installing Docker on Ubuntu..."

  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo tee /etc/apt/keyrings/docker.asc > /dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
}

# Function to install Docker on Debian
install_docker_debian() {
  echo "Installing Docker on Debian..."

  for pkg in docker.io docker-doc podman-docker containerd runc; do
    sudo apt-get remove -y $pkg || true
  done

  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | \
    sudo tee /etc/apt/keyrings/docker.asc > /dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
}

# Function to install Docker on RHEL/CentOS
install_docker_rhel() {
  echo "Installing Docker on RHEL/CentOS..."

  sudo dnf remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    podman \
    runc || true

  sudo dnf -y install dnf-plugins-core
  sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

  sudo dnf install -y docker-ce docker-ce-cli containerd.io
  sudo systemctl enable --now docker
}

# Detect OS and run appropriate installer
case "$ID" in
  ubuntu)
    install_docker_ubuntu
    ;;
  debian)
    install_docker_debian
    ;;
  rhel|centos|fedora)
    install_docker_rhel
    ;;
  *)
    echo "Unsupported OS: $ID"
    exit 1
    ;;
esac

# Verify installation
echo "Docker version:"
docker --version

