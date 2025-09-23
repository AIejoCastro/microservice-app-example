#!/bin/bash
set -e

echo "Building and pushing Docker images..."

REGISTRY_SERVER=${REGISTRY_LOGIN_SERVER}
SERVICES=("auth-api" "users-api" "todos-api" "frontend" "log-message-processor")

for SERVICE in "${SERVICES[@]}"; do
    echo "Building $SERVICE..."
    
    # Build the image
    docker build -t $SERVICE:latest $SERVICE/
    
    # Tag for registry
    docker tag $SERVICE:latest $REGISTRY_SERVER/$SERVICE:latest
    
    # Push to registry
    docker push $REGISTRY_SERVER/$SERVICE:latest
    
    echo "Pushed $SERVICE to registry"
done

echo "All images built and pushed successfully!"