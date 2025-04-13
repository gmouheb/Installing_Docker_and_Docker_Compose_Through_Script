#!/bin/bash
#set -e  # Exit on any error

echo "Detecting OS..."
# Only source if the file exists
if [ -f /etc/os-release ]; then
    source /etc/os-release
else
    echo "Cannot detect OS: /etc/os-release not found"
    exit 1
fi

# Function to install Docker on Ubuntu/Kali
install_docker_ubuntu() {
    echo "Installing Docker on Ubuntu/Kali..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Handle Kali Linux differently (using Ubuntu's repo)
    if [ "$ID" = "kali" ]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    else
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi
    
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
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
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
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
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
}

# Detect OS and run appropriate installer
case "$ID" in
    ubuntu)
        install_docker_ubuntu
        ;;
    kali)
        echo "Detected Kali Linux. Using Ubuntu Docker repository..."
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
        echo "Press Enter to exit..."
        read
        exit 1
        ;;
esac

# Start Docker service
sudo systemctl start docker || sudo service docker start

# Add current user to docker group
sudo usermod -aG docker "$USER"
echo "Added $USER to the docker group. You'll need to log out and back in for this to take effect."

# Verify installation
echo "Docker version:"
docker --version || echo "Docker installation might have failed. Please check the output for errors."

echo "Docker installation completed."
echo "Press Enter to exit..."
read -r
