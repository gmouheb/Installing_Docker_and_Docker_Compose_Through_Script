#!/bin/bash
set -e

echo "Installing Docker Compose..."

# Check if we have curl installed
if ! command -v curl &> /dev/null; then
    echo "curl not found, installing..."
    sudo apt-get update && sudo apt-get install -y curl || sudo dnf install -y curl
fi

# Detect system architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Normalize architecture names
case "$ARCH" in
    x86_64) ARCH="x86_64" ;;
    aarch64 | arm64) ARCH="aarch64" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        echo "Press Enter to exit..."
        read -r
        exit 1
        ;;
esac

# Set platform name for GitHub binary
PLATFORM="${OS}-${ARCH}"  # e.g. linux-x86_64

# Try to get the latest version or use a fallback version if GitHub API fails
echo "Fetching latest Docker Compose version..."
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' || echo "v2.24.6")

if [ -z "$COMPOSE_VERSION" ]; then
    COMPOSE_VERSION="v2.24.6"  # Fallback to a known version
    echo "Could not fetch latest version, using fallback version: $COMPOSE_VERSION"
else
    echo "Found latest version: $COMPOSE_VERSION"
fi

echo "Installing Docker Compose version: $COMPOSE_VERSION for $PLATFORM"

# Create directory if it doesn't exist
sudo mkdir -p /usr/local/bin

# Download Docker Compose binary
sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-${PLATFORM}" -o /usr/local/bin/docker-compose

# Apply executable permissions
sudo chmod +x /usr/local/bin/docker-compose

# Create symbolic link for compatibility
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose 2>/dev/null || true

# Verify installation
echo "Docker Compose installed at /usr/local/bin/docker-compose"

if docker-compose version; then
    echo "Docker Compose installation successful."
else
    echo "Docker Compose installation might have failed. Please check the output for errors."
fi

echo "Docker Compose installation completed."
echo "Press Enter to exit..."
read -r
