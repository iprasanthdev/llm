FROM ollama/ollama

# Set the maintainer label (optional)
LABEL maintainer="your_email@example.com"

# Create a volume for ollama data
VOLUME /root/.ollama

# Expose the port
EXPOSE 11434