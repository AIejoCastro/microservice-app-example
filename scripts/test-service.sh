#!/bin/bash
set -e

SERVICE=$1

echo "Testing service: $SERVICE"

case $SERVICE in
  "auth-api")
    cd auth-api
    go test ./...
    ;;
  "users-api")
    cd users-api
    mvn test
    ;;
  "todos-api")
    cd todos-api
    npm test
    ;;
  "frontend")
    cd frontend
    npm run test:unit
    ;;
  "log-message-processor")
    cd log-message-processor
    python -m pytest tests/
    ;;
  *)
    echo "Unknown service: $SERVICE"
    exit 1
    ;;
esac

echo "Tests completed for $SERVICE"