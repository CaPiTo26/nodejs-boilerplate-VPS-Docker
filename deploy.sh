#!/bin/bash

set -e  # or set -euxo pipefail for more thorough checks

# Move into the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load environment variables from a .env file, if it exists
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

# Validate essential variables (exit if any is missing)
: "${REGISTRY_USER:?REGISTRY_USER variable is not defined}"
: "${IMAGE_NAME:?IMAGE_NAME variable is not defined}"
: "${TAG:=latest}"
: "${SERVER_USER:?SERVER_USER variable is not defined}"
: "${SERVER_HOST:?SERVER_HOST variable is not defined}"
: "${CONTAINER_NAME:?CONTAINER_NAME variable is not defined}"
: "${DOCKER_PORTS:=-p 3000:3000}"
: "${DOCKER_ADDITIONAL_ARGS:=}"
: "${DOCKERFILE_PATH_FOLDER:?DOCKERFILE_PATH_FOLDER variable is not defined}"

# 1. Build the Docker image locally with the complete name
docker build -t "$REGISTRY_USER/$IMAGE_NAME:$TAG" -f "$DOCKERFILE_PATH_FOLDER/Dockerfile" "$DOCKERFILE_PATH_FOLDER"

# 2. Push the Docker image to the registry
docker push "$REGISTRY_USER/$IMAGE_NAME:$TAG"

# 3. Connect via SSH to deploy
ssh "${SERVER_USER}@${SERVER_HOST}" << EOF
    sudo -i
    
    # Stop and remove the old container if it exists
    docker stop $CONTAINER_NAME || true
    docker rm $CONTAINER_NAME || true

    # Pull the new image
    docker pull $REGISTRY_USER/$IMAGE_NAME:$TAG

    # Run a new container
    docker run -d \
      --name $CONTAINER_NAME \
      $DOCKER_PORTS \
      $DOCKER_ADDITIONAL_ARGS \
      $REGISTRY_USER/$IMAGE_NAME:$TAG
      
    # Clean up unused images
    docker image prune -a -f
EOF
