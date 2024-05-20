#!/bin/bash

echo "Installing Ollama model inside the Docker container..."

# Pull the model using the Ollama CLI within the Docker container
docker exec -it llmservice-ollama-1 ollama pull mistral

# Check the exit status of the previous command
if [ $? -ne 0 ]; then
    echo "Failed to pull the Ollama model."
    exit 1
else
    echo "Successfully pulled the Ollama model."
fi
# Alternative way to pull the ollama model
# curl -X POST \
# -H "Content-Type: application/json" \
# -d '{"name":"mistral"}' \
#  http://localhost:11434/api/pull
