#!/bin/bash

echo "Starting Ollama service deployment..."

# Detect if the OS is macOS and skip NVIDIA setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS detected. Using CPU only for Ollama."
    GPU_FLAG=""
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    GPU_FLAG="--gpus all"
else
    # For Linux, attempt to configure NVIDIA if available
    GPU_FLAG=""
fi

# Determine OS and configure installation commands
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    INSTALL_CMD="sudo apt-get install -y"
    UPDATE_CMD="sudo apt-get update"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Assuming Homebrew is installed on macOS
    INSTALL_CMD="brew install"
    UPDATE_CMD="brew update"
else
    echo "Unsupported OS for this script."
    exit 1
fi

# Ensure jq is installed for parsing JSON
echo "Checking for jq..."
if ! command -v jq &> /dev/null; then
    echo "jq could not be found, installing..."
    $UPDATE_CMD && $INSTALL_CMD jq
else
    echo "jq is already installed."
fi


# Make sure the necessary scripts are executable
#chmod -R 755 /Users/saravanan/.ollama/models
#chmod +x install_ollama_model.sh scale_and_monitor.sh

# Install Docker (skip if Docker Desktop is used on macOS)
echo "Installing Docker..."
./install_docker.sh

# Install Docker Compose (conditional for macOS)
echo "Installing Docker Compose..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    COMPOSE_VERSION=${1:-$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)}
    if ! command -v docker-compose &> /dev/null; then
        echo "Using Docker Compose version $COMPOSE_VERSION"
        sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        # Optional: Install command completion
        sudo curl -L "https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose" -o /etc/bash_completion.d/docker-compose

        echo "Docker Compose installed successfully."
    else
        echo "Docker Compose is already installed."
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Docker Desktop on macOS includes Docker Compose. Skipping separate installation."
fi

# Launch services with Docker Compose
echo "Starting services with Docker Compose..."
docker-compose up -d

echo "Waiting for Ollama service to be ready..."
# Wait until the Docker container is running
until docker ps | grep -q 'ollama-1'; do
    echo "Waiting for Ollama Docker container..."
    sleep 5
done
echo "Ollama Docker container is ready."

echo "Initiating scaling and monitoring..."
./scale_and_monitor.sh &

echo "Ollama service deployment completed."

# Now, directly call the script to handle Ollama model installation and service start
echo "Executing script for Ollama model installation and service initialization..."
./install_ollama_model.sh

