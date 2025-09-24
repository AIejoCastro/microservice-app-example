#!/bin/bash
set -e

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

echo "Deploying to Azure - Environment: $ENVIRONMENT"

case $ENVIRONMENT in
  "staging")
    RESOURCE_GROUP="microservice-app-staging-rg"
    APP_NAME_PREFIX="microapp-staging"
    REGISTRY_NAME="microappregistry"
    ;;
  "production")
    RESOURCE_GROUP="microservice-app-rg"
    APP_NAME_PREFIX="microapp"
    REGISTRY_NAME="microappregistry"
    ;;
  *)
    echo "Unknown environment: $ENVIRONMENT"
    exit 1
    ;;
esac

# -----------------------
# Web Apps (APIs + Frontend)
# -----------------------
declare -A SERVICES
SERVICES["auth"]="auth-api"
SERVICES["users"]="users-api"
SERVICES["todos"]="todos-api"
SERVICES["frontend"]="frontend"

for SERVICE in "${!SERVICES[@]}"; do
    APP_NAME="$APP_NAME_PREFIX-$SERVICE"
    IMAGE_NAME="${SERVICES[$SERVICE]}"
    
    echo "Configuring $APP_NAME with image $REGISTRY_NAME.azurecr.io/$IMAGE_NAME:latest..."
    
    az webapp config set \
        --name $APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --linux-fx-version "DOCKER|$REGISTRY_NAME.azurecr.io/$IMAGE_NAME:latest"
    
    echo "Setting app configuration for $APP_NAME..."
    az webapp config appsettings set \
        --name $APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --settings \
            PORT=80 \
            WEBSITES_PORT=80 \
            WEBSITES_ENABLE_APP_SERVICE_STORAGE=false \
            SCM_DO_BUILD_DURING_DEPLOYMENT=false
    
    echo "Restarting $APP_NAME..."
    az webapp restart --name $APP_NAME --resource-group $RESOURCE_GROUP
    
    echo "Waiting for $APP_NAME to be ready..."
    sleep 15
    
    STATE=$(az webapp show --name $APP_NAME --resource-group $RESOURCE_GROUP --query "state" -o tsv)
    echo "$APP_NAME state: $STATE"
done

# -----------------------
# Container App (Log Processor)
# -----------------------
LOGPROCESSOR_NAME="$APP_NAME_PREFIX-logprocessor"
IMAGE_NAME="log-message-processor"

echo "Updating $LOGPROCESSOR_NAME as a Container App..."
az containerapp update \
    --name $LOGPROCESSOR_NAME \
    --resource-group $RESOURCE_GROUP \
    --image $REGISTRY_NAME.azurecr.io/$IMAGE_NAME:latest

echo "$LOGPROCESSOR_NAME updated successfully!"
