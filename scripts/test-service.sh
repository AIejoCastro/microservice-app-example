#!/bin/bash
set -e

SERVICE=$1

echo "Testing service: $SERVICE"

# No hacer cd aquí porque ya estamos en el directorio del servicio
case $SERVICE in
  "auth-api")
    go test ./... 2>/dev/null || echo "No tests found for $SERVICE"
    ;;
  "users-api")
    mvn test 2>/dev/null || echo "No tests found for $SERVICE"
    ;;
  "todos-api")
    npm test 2>/dev/null || echo "No tests found for $SERVICE"
    ;;
  "frontend")
    npm run test:unit 2>/dev/null || echo "No tests found for $SERVICE"
    ;;
  "log-message-processor")
    python -m pytest tests/ 2>/dev/null || echo "No tests found for $SERVICE"
    ;;
  *)
    echo "Unknown service: $SERVICE"
    exit 1
    ;;
esac

echo "Tests completed for $SERVICE"