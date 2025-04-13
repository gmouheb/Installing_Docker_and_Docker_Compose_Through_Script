#!/bin/bash

# Exit on error
set -e

# Update the package index
sudo apt-get update -y

# Install Docker Compose CLI plugin (official way)
sudo apt-get install -y docker-compose-plugin

# Verify the Docker Compose installation
sudo docker compose version
