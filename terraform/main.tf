terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.common_tags
}

# Container Registry
resource "azurerm_container_registry" "main" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = var.common_tags
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"

  tags = var.common_tags
}

# Redis Cache
resource "azurerm_redis_cache" "main" {
  name                = var.redis_cache_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  minimum_tls_version = "1.2"

  redis_configuration {
    maxmemory_policy = "allkeys-lru"
  }

  tags = var.common_tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = var.app_insights_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"

  tags = var.common_tags

  lifecycle {
    ignore_changes = [workspace_id]
  }
}

# App Services for each microservice
module "auth_api" {
  source = "./modules/app-service"

  app_name            = "${var.app_name_prefix}-auth"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

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

  depends_on = [
    azurerm_container_registry.main,
    azurerm_redis_cache.main,
    azurerm_application_insights.main
  ]
}

module "users_api" {
  source = "./modules/app-service"

  app_name            = "${var.app_name_prefix}-users"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  docker_image = "${azurerm_container_registry.main.login_server}/users-api:latest"

  enable_autoscaling = false
  create_autoscale   = false

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

  depends_on = [
    azurerm_container_registry.main,
    azurerm_redis_cache.main,
    azurerm_application_insights.main
  ]
}

module "todos_api" {
  source = "./modules/app-service"

  app_name            = "${var.app_name_prefix}-todos"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  docker_image = "${azurerm_container_registry.main.login_server}/todos-api:latest"

  enable_autoscaling = false
  create_autoscale   = false

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

  depends_on = [
    azurerm_container_registry.main,
    azurerm_redis_cache.main,
    azurerm_application_insights.main
  ]
}

module "frontend" {
  source = "./modules/app-service"

  app_name            = "${var.app_name_prefix}-frontend"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  docker_image = "${azurerm_container_registry.main.login_server}/frontend:latest"

  enable_autoscaling = false
  create_autoscale   = false

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.main.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.main.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.main.admin_password
    VUE_APP_AUTH_API_URL            = "https://${var.app_name_prefix}-auth.azurewebsites.net"
    VUE_APP_USERS_API_URL           = "https://${var.app_name_prefix}-users.azurewebsites.net"
    VUE_APP_TODOS_API_URL           = "https://${var.app_name_prefix}-todos.azurewebsites.net"
    APPINSIGHTS_INSTRUMENTATIONKEY  = azurerm_application_insights.main.instrumentation_key
  }

  tags = var.common_tags

  depends_on = [
    azurerm_container_registry.main,
    azurerm_application_insights.main
  ]
}

# Container App Environment
resource "azurerm_container_app_environment" "main" {
  name                = "${var.app_name_prefix}-cae"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Log Message Processor as Container App
resource "azurerm_container_app" "log_message_processor" {
  name                         = "${var.app_name_prefix}-logprocessor"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode                = "Single"

  template {
    container {
      name   = "log-message-processor"
      image  = "${azurerm_container_registry.main.login_server}/log-message-processor:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "REDIS_HOST"
        value = azurerm_redis_cache.main.hostname
      }
      env {
        name  = "REDIS_PORT"
        value = azurerm_redis_cache.main.port
      }
      env {
        name  = "REDIS_PASSWORD"
        value = azurerm_redis_cache.main.primary_access_key
      }
      env {
        name  = "APPINSIGHTS_INSTRUMENTATIONKEY"
        value = azurerm_application_insights.main.instrumentation_key
      }
      env {
        name  = "REDIS_CHANNEL"
        value = "logs"
      }
      env {
        name  = "ZIPKIN_URL"
        value = "http://${var.app_name_prefix}-zipkin:9411/api/v1/spans"
      }
    }
  }

  secret {
    name  = "acr-admin-password"
    value = azurerm_container_registry.main.admin_password
  }

  registry {
    server               = azurerm_container_registry.main.login_server
    username             = azurerm_container_registry.main.admin_username
    password_secret_name = "acr-admin-password"
  }

  tags = var.common_tags

  depends_on = [
    azurerm_container_registry.main,
    azurerm_redis_cache.main,
    azurerm_application_insights.main
  ]
}
