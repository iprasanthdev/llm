#!/bin/bash

SCALE_UP_THRESHOLD=80
SCALE_DOWN_THRESHOLD=20

# Function to get current load (e.g., CPU usage, number of requests, etc.)
get_current_load() {
    # This function will fetch the current system CPU load
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # On Linux, use the `top` command to get CPU usage
        top -bn2 | grep "Cpu(s)" | tail -n 1 | awk '{print 100-$8}'  # Idle CPU
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # On macOS, use the `top` command as well, but with different options
        top -l 2 | grep "CPU usage" | tail -n 1 | awk '{print $3}' | cut -d '%' -f1
    fi
}

# Function to get the number of GPUs available
get_gpu_count() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # On Linux with Nvidia GPUs, use `nvidia-smi`
        if command -v nvidia-smi &> /dev/null; then
            nvidia-smi -L | wc -l
        else
            echo "0"  # No Nvidia GPUs found, assuming 0
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # For macOS, you might check for Metal device availability
        # The following command lists available Metal devices and counts them
        system_profiler SPDisplaysDataType | grep "Metal" | wc -l
    fi
}

# Function to scale the Ollama service
scale_ollama() {
    local target_scale="$1" # The desired scale, calculated based on load and GPU count
    echo "Scaling Ollama service to $target_scale instances..."
    docker-compose up -d --scale ollama="$target_scale"
}

# Main monitoring and scaling logic
main() {
    # while true; do
        local current_load=$(get_current_load)
        local gpu_count=$(get_gpu_count)
        local target_scale=1

        echo "Current Load: $current_load, GPU Count: $gpu_count"

        if (( $(echo "$current_load >= $SCALE_UP_THRESHOLD" | bc -l) )); then
            echo "Scaling up due to high load..."
            target_scale=$(echo "scale=0; $current_load / $SCALE_UP_THRESHOLD * $gpu_count" | bc)

            # Ensuring we don't exceed GPU count
            target_scale=$(($target_scale > $gpu_count ? $gpu_count : $target_scale))
            scale_ollama "$target_scale"
        elif (( $(echo "$current_load <= $SCALE_DOWN_THRESHOLD" | bc -l) )); then
            echo "Scaling down due to low load..."
            scale_ollama 1
        else
            echo "Load is balanced. No scaling performed."
        fi

        sleep 60
    # done
}

main