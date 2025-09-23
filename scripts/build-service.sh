#!/bin/bash
set -e

SERVICE=$1

echo "Building service: $SERVICE"

# No hacer cd aquí porque ya estamos en el directorio del servicio
case $SERVICE in
  "auth-api")
    go mod download
    go build -o main .
    ;;
  "users-api")
    mvn clean compile
    ;;
  "todos-api")
    npm ci
    npm run build 2>/dev/null || echo "No build script found"
    ;;
  "frontend")
    npm ci
    npm run build
    ;;
  "log-message-processor")
    pip install -r requirements.txt
    ;;
  *)
    echo "Unknown service: $SERVICE"
    exit 1
    ;;
esac

echo "Build completed for $SERVICE"