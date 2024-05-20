# Use the ollama image as the base
FROM ollama/ollama

# Set environment variables
ENV MODEL_NAME mistral

# Create a directory for the model data
RUN mkdir -p /root/.ollama

# Set the working directory
WORKDIR /root/.ollama

# Copy a bash script into the container
COPY deploy_ollama_script.sh /root/.ollama/deploy_ollama_script.sh
COPY docker-compose.yml /root/.ollama/docker-compose.yml
COPY install_docker.sh /root/.ollama/install_docker.sh
COPY install_ollama_model.sh /root/.ollama/install_ollama_model.sh
COPY scale_and_monitor.sh /root/.ollama/scale_and_monitor.sh

# Make the bash script executable
RUN chmod +x /root/.ollama/deploy_ollama_script.sh
RUN chmod +x /root/.ollama/docker-compose.sh
RUN chmod +x /root/.ollama/install_docker.sh
RUN chmod +x /root/.ollama/install_ollama_model.sh
RUN chmod +x /root/.ollama/scale_and_monitor.sh

# Expose the required port
EXPOSE 11434

# Pull the Mistral model
RUN ollama pull $MODEL_NAME

# Run the bash script
CMD ["/bin/bash", "/root/.ollama/deploy_ollama_script.sh"]
