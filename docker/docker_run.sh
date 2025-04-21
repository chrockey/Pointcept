#!/bin/bash

# print the commands
set -o xtrace

# Run docker image as an argument but use realworld by default
DATASET_PATH=${1:-"datasets"}
DATASET2_PATH=${2:-"datasets2"}
DOCKER_IMAGE=${3:-"pointcept"}

USER=$(whoami)

# Check if container already exists
if docker ps -a | grep -q "pointcept"; then
    echo "Error: Container 'pointcept' already exists. Please remove it first with 'docker rm pointcept' if you want to create a new one."
    exit 1
fi

# Mount the current path to /workspace
docker run \
    --gpus all \
    --shm-size=32g \
    -it \
    --name pointcept \
    -v "/home/${USER}:/root" \
    -v "$(pwd):/workspace" \
    -v "${DATASET_PATH}:/datasets" \
    -v "${DATASET2_PATH}:/datasets2" \
    --workdir /workspace \
    --device=/dev/nvidiactl \
    --device=/dev/nvidia0 \
    --device=/dev/nvidia1 \
    --device=/dev/nvidia2 \
    --device=/dev/nvidia3 \
    --device=/dev/nvidia4 \
    --device=/dev/nvidia5 \
    --device=/dev/nvidia6 \
    --device=/dev/nvidia7 \
    --device=/dev/nvidia-modeset \
    --device=/dev/nvidia-uvm \
    --device=/dev/nvidia-uvm-tools \
    "$DOCKER_IMAGE" \
    /bin/zsh