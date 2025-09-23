# App Services for each microservice
module "auth_api" {
  source = "./modules/app-service"
  
  app_name            = "${var.app_name_prefix}-auth"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  
  # Formato correcto para docker_image
  docker_image = "${azurerm_container_registry.main.login_server}/auth-api:latest"
  
  enable_autoscaling = var.enable_autoscaling
  create_autoscale   = true
  
  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.main.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.main.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.main.admin_password
    REDIS_HOST                      = azurerm_redis_cache.main.hostname
    REDIS_PORT                      = azurerm_redis_cache.main.port
    REDIS_PASSWORD                  = azurerm_redis_cache.main.primary_access_key
    APPINSIGHTS_INSTRUMENTATIONKEY  = azurerm_application_insights.main.instrumentation_key
  }
  
  tags = var.common_tags
}

module "users_api" {
  source = "./modules/app-service"
  
  app_name            = "${var.app_name_prefix}-users"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  
  docker_image = "${azurerm_container_registry.main.login_server}/users-api:latest"
  
  # Don't create autoscale - already created by auth_api
  enable_autoscaling = false
  create_autoscale   = false
  
  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = azurerm_container_registry.main.login_server
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.main.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.main.admin_password
    REDIS_HOST                      = azurerm_redis_cache.main.hostname
    REDIS_PORT                      = azurerm_redis_cache.main.port
    REDIS_PASSWORD                  = azurerm_redis_cache.main.primary_access_key
    APPINSIGHTS_INSTRUMENTATIONKEY  = azurerm_application_insights.main.instrumentation_key
  }
  
  tags = var.common_tags
}

module "todos_api" {
  source = "./modules/app-service"
  
  app_name            = "${var.app_name_prefix}-todos"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  
  docker_image = "${azurerm_container_registry.main.login_server}/todos-api:latest"
  
  # Don't create autoscale - already created by auth_api
  enable_autoscaling = false
  create_autoscale   = false
  
  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = azurerm_container_registry.main.login_server
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.main.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.main.admin_password
    REDIS_HOST                      = azurerm_redis_cache.main.hostname
    REDIS_PORT                      = azurerm_redis_cache.main.port
    REDIS_PASSWORD                  = azurerm_redis_cache.main.primary_access_key
    APPINSIGHTS_INSTRUMENTATIONKEY  = azurerm_application_insights.main.instrumentation_key
  }
  
  tags = var.common_tags
}

module "frontend" {
  source = "./modules/app-service"
  
  app_name            = "${var.app_name_prefix}-frontend"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  
  docker_image = "${azurerm_container_registry.main.login_server}/frontend:latest"
  
  # Don't create autoscale - already created by auth_api
  enable_autoscaling = false
  create_autoscale   = false
  
  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = azurerm_container_registry.main.login_server
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.main.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.main.admin_password
    VUE_APP_AUTH_API_URL            = "https://${var.app_name_prefix}-auth.azurewebsites.net"
    VUE_APP_USERS_API_URL           = "https://${var.app_name_prefix}-users.azurewebsites.net"
    VUE_APP_TODOS_API_URL           = "https://${var.app_name_prefix}-todos.azurewebsites.net"
    APPINSIGHTS_INSTRUMENTATIONKEY  = azurerm_application_insights.main.instrumentation_key
  }
  
  tags = var.common_tags
}

# Remove Container Instance for log processor - will be handled by development pipeline
# The error shows the Docker images aren't built yet

# Container Instance for Log Processor (background service)
# Commented out until Docker images are available
/*
resource "azurerm_container_group" "log_processor" {
  name                = "${var.app_name_prefix}-log-processor"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_address_type     = "None"
  os_type             = "Linux"
  restart_policy      = "Always"

  image_registry_credential {
    username = azurerm_container_registry.main.admin_username
    password = azurerm_container_registry.main.admin_password
    server   = azurerm_container_registry.main.login_server
  }

  container {
    name   = "log-message-processor"
    image  = "${azurerm_container_registry.main.login_server}/log-message-processor:latest"
    cpu    = 0.5
    memory = 1

    environment_variables = {
      REDIS_HOST     = azurerm_redis_cache.main.hostname
      REDIS_PORT     = azurerm_redis_cache.main.port
      REDIS_PASSWORD = azurerm_redis_cache.main.primary_access_key
    }
  }

  tags = var.common_tags
}
*/