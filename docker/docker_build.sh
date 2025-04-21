#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS] [VERSION]"
    echo "Options:"
    echo "  -p, --push    Push the Docker image after building"
    echo "  -h, --help    Display this help message"
    echo "  -t, --tag     Tag the Docker image with the provided version"
    echo "  -n, --no-cache Build the Docker image without using cache"
    echo "VERSION defaults to 'latest' if not provided"
}

# Initialize variables
PUSH=false
VERSION="latest"
TAG="pointcept:${VERSION}"
NO_CACHE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p | --push)
            PUSH=true
            shift
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        -t | --tag)
            TAG=$2
            shift 2
            ;;
        -n | --no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        *)
            VERSION=$1
            shift
            ;;
    esac
done

IMAGE_URL="chrockey/pointcept:${VERSION}"

# Build the Docker image
# Add --no-cache to force a rebuild
echo "Building Docker image..."
docker build \
    $NO_CACHE \
    -t "$TAG" \
    -f docker/Dockerfile .

# Test docker
if ! docker run --gpus all -it --rm "$TAG" python -c "import torch; import spconv; import pointops; import pointgroup_ops; print(f'CUDA available: {torch.cuda.is_available()}\nspconv version: {spconv.__version__}');"; then
    echo "Docker test failed"
    exit 1
fi

# Tag the image
docker tag "$TAG" "$IMAGE_URL"

# shellcheck disable=SC2181
# Push the Docker image if requested
if [ "$PUSH" = true ]; then
    echo "Pushing Docker image..."
    docker push "$IMAGE_URL"
    if [ $? -ne 0 ]; then
        echo "Docker push failed"
        exit 1
    fi
    echo "Docker image pushed successfully"
else
    echo "Docker image built and tested successfully"
    echo "To push the image, run the script with the -p or --push option"
fi