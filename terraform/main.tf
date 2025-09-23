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

# Redis Cache (Cache Aside Pattern)
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
  workspace_id        = null

  tags = var.common_tags
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
}