#!/bin/bash

# Update the package index
sudo apt-get update

# Install Docker CE
sudo apt-get install -y docker.io

# Add the current user to the Docker group to run Docker as a non-root user
sudo usermod -aG docker $USER

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

echo "Docker installed successfully."