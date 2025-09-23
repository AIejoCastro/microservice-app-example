#!/bin/bash
set -e

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

echo "Deploying to Azure - Environment: $ENVIRONMENT"

# Set environment-specific variables
case $ENVIRONMENT in
  "staging")
    RESOURCE_GROUP="microservice-app-staging-rg"
    APP_NAME_PREFIX="microapp-staging"
    ;;
  "production")
    RESOURCE_GROUP="microservice-app-rg"
    APP_NAME_PREFIX="microapp"
    ;;
  *)
    echo "Unknown environment: $ENVIRONMENT"
    exit 1
    ;;
esac

SERVICES=("auth" "users" "todos" "frontend")

for SERVICE in "${SERVICES[@]}"; do
    APP_NAME="$APP_NAME_PREFIX-$SERVICE"
    
    echo "Restarting $APP_NAME..."
    az webapp restart --name $APP_NAME --resource-group $RESOURCE_GROUP
    
    echo "Waiting for $APP_NAME to be ready..."
    az webapp show --name $APP_NAME --resource-group $RESOURCE_GROUP --query "state" -o tsv
done

echo "Deployment to $ENVIRONMENT completed!"