#!/bin/bash
set -e

echo "Building and pushing Docker images..."

# Usa directamente tu ACR
REGISTRY_SERVER="microappregistry.azurecr.io"
SERVICES=("auth-api" "users-api" "todos-api" "frontend" "log-message-processor")

for SERVICE in "${SERVICES[@]}"; do
    echo "📦 Building $SERVICE..."
    
    # Build the image con el nombre local
    docker build -t $SERVICE:latest $SERVICE/
    
    # Etiquetar para el registro
    docker tag $SERVICE:latest $REGISTRY_SERVER/$SERVICE:latest
    
    # Push al ACR
    docker push $REGISTRY_SERVER/$SERVICE:latest
    
    echo "✅ Pushed $SERVICE to $REGISTRY_SERVER"
done

echo "🎉 All images built and pushed successfully!"
