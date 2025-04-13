#!/bin/bash

# Docker and Docker Compose Installation Script for Kali Linux
# This script installs Docker and Docker Compose on Kali Linux

# Function to display colored output
print_status() {
  if [ "$2" = "success" ]; then
    echo -e "\e[32m[✓] $1\e[0m"  # Green text
  elif [ "$2" = "error" ]; then
    echo -e "\e[31m[✗] $1\e[0m"  # Red text
  elif [ "$2" = "warning" ]; then
    echo -e "\e[33m[⚠] $1\e[0m"  # Yellow text
  else
    echo -e "\e[34m[*] $1\e[0m"  # Blue text
  fi
}

# Function to handle errors but continue execution
run_cmd() {
  print_status "Running: $*"
  if "$@"; then
    print_status "Command completed successfully." "success"
  else
    local exit_code=$?
    print_status "Command failed with exit code $exit_code: $*" "error"
    print_status "Continuing with script execution..." "warning"
  fi
}

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
  print_status "Please run this script as a regular user with sudo privileges, not as root." "error"
  print_status "The script will add your user to the docker group." "info"
  read -p "Press Enter to exit..."
  exit 1
fi

# Print welcome message
print_status "Starting Docker and Docker Compose installation for Kali Linux" "info"
print_status "This script will install Docker and Docker Compose on your system." "info"

# Update package repositories
print_status "Updating package repositories..." "info"
run_cmd sudo apt update

# Install dependencies
print_status "Installing required dependencies..." "info"
run_cmd sudo apt install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  software-properties-common

# Remove any old Docker installations
print_status "Removing any existing Docker installations..." "info"
run_cmd sudo apt remove --purge -y docker docker-engine docker.io containerd runc || true

# Create directory for Docker GPG key
print_status "Setting up Docker repository..." "info"
run_cmd sudo install -m 0755 -d /etc/apt/keyrings

# Add Docker's official GPG key
print_status "Adding Docker's GPG key..." "info"
if ! curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
  print_status "Failed to download Docker GPG key. Trying alternative method..." "warning"
  run_cmd curl -fsSL https://download.docker.com/linux/debian/gpg -o /tmp/docker.gpg
  run_cmd sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg /tmp/docker.gpg
  run_cmd rm -f /tmp/docker.gpg
fi
run_cmd sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Determine Debian version to use for Docker repository
DEBIAN_VERSION="bullseye"  # Debian 11 - Compatible with recent Kali
print_status "Using Debian $DEBIAN_VERSION repository for Docker installation" "info"

# Add Docker repository to apt sources
print_status "Adding Docker repository to apt sources..." "info"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $DEBIAN_VERSION stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists with new repository
print_status "Updating package lists with Docker repository..." "info"
run_cmd sudo apt update

# Install Docker Engine and related packages
print_status "Installing Docker Engine..." "info"
run_cmd sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
print_status "Starting Docker service..." "info"
run_cmd sudo systemctl enable docker
run_cmd sudo systemctl start docker

# Add current user to docker group
print_status "Adding user $(whoami) to the docker group..." "info"
run_cmd sudo usermod -aG docker "$(whoami)"
print_status "NOTE: You'll need to log out and back in for the docker group changes to take effect." "warning"

# Verify Docker installation
print_status "Verifying Docker installation..." "info"
if ! sudo docker --version; then
  print_status "Docker installation verification failed." "error"
else
  print_status "Docker installed successfully!" "success"
fi

# Install Docker Compose
print_status "Installing Docker Compose..." "info"

# Try to get latest version from GitHub API, fall back to known version if that fails
print_status "Fetching latest Docker Compose version..." "info"
if COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'); then
  print_status "Found latest version: $COMPOSE_VERSION" "success"
else
  COMPOSE_VERSION="v2.24.6"  # Fallback version
  print_status "Could not fetch latest version, using fallback version: $COMPOSE_VERSION" "warning"
fi

# Detect system architecture
OS="linux"
ARCH=$(uname -m)

# Normalize architecture names
case "$ARCH" in
  x86_64) ARCH="x86_64" ;;
  aarch64|arm64) ARCH="aarch64" ;;
  armv7l) ARCH="armv7" ;;
  *)
    print_status "Unsupported architecture: $ARCH" "warning"
    print_status "Docker Compose installation might fail. Attempting anyway..." "warning"
    ;;
esac

# Download and install Docker Compose
print_status "Downloading Docker Compose $COMPOSE_VERSION for $OS-$ARCH..." "info"
COMPOSE_URL="https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-${OS}-${ARCH}"
run_cmd sudo curl -L "$COMPOSE_URL" -o /usr/local/bin/docker-compose
run_cmd sudo chmod +x /usr/local/bin/docker-compose

# Create symbolic link for better compatibility
run_cmd sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose 2>/dev/null || true

# Check Docker Compose installation
print_status "Verifying Docker Compose installation..." "info"
if ! sudo docker-compose --version; then
  print_status "Docker Compose installation verification failed." "error"
else
  print_status "Docker Compose installed successfully!" "success"
fi

# Run hello-world container to verify installation
print_status "Running test container (hello-world) to verify Docker functionality..." "info"
if sudo docker run --rm hello-world > /tmp/docker-test.log 2>&1; then
  print_status "Docker test successful! The hello-world container ran properly." "success"
  # Show the hello-world output
  echo -e "\nOutput from hello-world container:"
  cat /tmp/docker-test.log
  rm -f /tmp/docker-test.log
else
  print_status "Docker test container failed to run. Docker may not be installed correctly." "error"
  print_status "Check /tmp/docker-test.log for details." "warning"
fi

# Print summary and next steps
print_status "=========================================" "info"
print_status "Installation Summary:" "info"
print_status "Docker: $(sudo docker --version 2>/dev/null || echo 'Not installed correctly')" "info"
print_status "Docker Compose: $(sudo docker-compose --version 2>/dev/null || echo 'Not installed correctly')" "info"
print_status "=========================================" "info"
print_status "IMPORTANT NOTES:" "warning"
print_status "1. You MUST log out and log back in for docker group membership to take effect." "warning"
print_status "2. Until you log out and back in, you'll need to use 'sudo' with docker commands." "warning"
print_status "3. After logging back in, you can run docker commands without sudo." "info"
print_status "4. To test your installation after logging back in, run: docker run hello-world" "info"
print_status "=========================================" "info"

# Keep terminal open
read -p "Press Enter to exit..."
exit 0