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

# Array de servicios con sus imágenes correspondientes
declare -A SERVICES
SERVICES["auth"]="auth-api"
SERVICES["users"]="users-api"
SERVICES["todos"]="todos-api"
SERVICES["frontend"]="frontend"

for SERVICE in "${!SERVICES[@]}"; do
    APP_NAME="$APP_NAME_PREFIX-$SERVICE"
    IMAGE_NAME="${SERVICES[$SERVICE]}"
    
    echo "Configuring $APP_NAME with image $REGISTRY_NAME.azurecr.io/$IMAGE_NAME:latest..."
    
    # Configurar la imagen Docker
    az webapp config set \
        --name $APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --linux-fx-version "DOCKER|$REGISTRY_NAME.azurecr.io/$IMAGE_NAME:latest"
    
    echo "Restarting $APP_NAME..."
    az webapp restart --name $APP_NAME --resource-group $RESOURCE_GROUP
    
    echo "Waiting for $APP_NAME to be ready..."
    sleep 10
    
    # Verificar el estado
    STATE=$(az webapp show --name $APP_NAME --resource-group $RESOURCE_GROUP --query "state" -o tsv)
    echo "$APP_NAME state: $STATE"
done

echo "Deployment to $ENVIRONMENT completed!"
echo "URLs:"
echo "  Frontend: https://$APP_NAME_PREFIX-frontend.azurewebsites.net"
echo "  Auth API: https://$APP_NAME_PREFIX-auth.azurewebsites.net"
echo "  Users API: https://$APP_NAME_PREFIX-users.azurewebsites.net"
echo "  TODOs API: https://$APP_NAME_PREFIX-todos.azurewebsites.net"