#!/bin/bash
set -e

SERVICE=$1

echo "Building service: $SERVICE"

case $SERVICE in
  "auth-api")
    cd auth-api
    go mod download
    go build -o main .
    ;;
  "users-api")
    cd users-api
    mvn clean compile
    ;;
  "todos-api")
    cd todos-api
    npm ci
    npm run build
    ;;
  "frontend")
    cd frontend
    npm ci
    npm run build
    ;;
  "log-message-processor")
    cd log-message-processor
    pip install -r requirements.txt
    ;;
  *)
    echo "Unknown service: $SERVICE"
    exit 1
    ;;
esac

echo "Build completed for $SERVICE"