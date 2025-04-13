#!/bin/bash
# Script to detect Linux OS type and install Docker Compose
# Supports: Ubuntu, Debian, and RHEL/CentOS

echo "Detecting OS..."
# Only source if the file exists
if [ -f /etc/os-release ]; then
    source /etc/os-release
else
    echo "Cannot detect OS: /etc/os-release not found"
    exit 1
fi

# Function to install Docker Compose on Ubuntu/Debian
install_docker_compose_debian_based() {
    echo "Installing Docker Compose on $ID..."
    
    # Check if Docker Compose is already installed
    if command -v docker-compose &> /dev/null; then
        echo "Docker Compose is already installed."
        docker-compose --version
        return
    fi
    
    # Install curl if it's not already installed
    if ! command -v curl &> /dev/null; then
        echo "Installing curl..."
        sudo apt-get update
        sudo apt-get install -y curl
    fi
    
    # Get the latest release of Docker Compose
    LATEST_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "tag_name" | cut -d '"' -f 4)
    
    # Create the directory for the binary
    sudo mkdir -p /usr/local/lib/docker/cli-plugins/
    
    # Download Docker Compose
    echo "Downloading Docker Compose ${LATEST_COMPOSE_VERSION}..."
    sudo curl -L "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/lib/docker/cli-plugins/docker-compose
    
    # Apply executable permissions
    sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
    
    # Create symbolic link for standalone use
    sudo ln -sf /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
    
    # Verify installation
    echo "Docker Compose version:"
    docker-compose --version || echo "Docker Compose installation might have failed. Please check the output for errors."
}

# Function to install Docker Compose on RHEL/CentOS
install_docker_compose_rhel_based() {
    echo "Installing Docker Compose on $ID..."
    
    # Check if Docker Compose is already installed
    if command -v docker-compose &> /dev/null; then
        echo "Docker Compose is already installed."
        docker-compose --version
        return
    fi
    
    # Install curl if it's not already installed
    if ! command -v curl &> /dev/null; then
        echo "Installing curl..."
        sudo dnf install -y curl
    fi
    
    # Get the latest release of Docker Compose
    LATEST_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "tag_name" | cut -d '"' -f 4)
    
    # Create the directory for the binary
    sudo mkdir -p /usr/local/lib/docker/cli-plugins/
    
    # Download Docker Compose
    echo "Downloading Docker Compose ${LATEST_COMPOSE_VERSION}..."
    sudo curl -L "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/lib/docker/cli-plugins/docker-compose
    
    # Apply executable permissions
    sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
    
    # Create symbolic link for standalone use
    sudo ln -sf /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
    
    # Verify installation
    echo "Docker Compose version:"
    docker-compose --version || echo "Docker Compose installation might have failed. Please check the output for errors."
}

# Detect OS and run appropriate installer
case "$ID" in
    ubuntu|linuxmint|elementary|pop|neon|kali)
        # Ubuntu and Ubuntu-based distributions
        install_docker_compose_debian_based
        ;;
    debian)
        # Debian
        install_docker_compose_debian_based
        ;;
    rhel|centos|fedora|rocky|alma|ol)
        # RHEL and RHEL-based distributions
        install_docker_compose_rhel_based
        ;;
    *)
        echo "Unsupported OS: $ID"
        echo "This script only supports Ubuntu, Debian, and RHEL/CentOS-based distributions."
        echo "Press Enter to exit..."
        read
        exit 1
        ;;
esac

echo "Docker Compose installation completed."
echo "Press Enter to exit..."
read -r
