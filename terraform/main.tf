terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfsa1758595608" # <- Cambiar por tu storage
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
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

  tags = var.common_tags
}

# App Services for each microservice
module "auth_api" {
  source = "./modules/app-service"

  app_name            = "${var.app_name_prefix}-auth"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  docker_image             = "auth-api:latest"
  docker_registry_url      = "https://${azurerm_container_registry.main.login_server}"
  docker_registry_username = azurerm_container_registry.main.admin_username
  docker_registry_password = azurerm_container_registry.main.admin_password

  app_settings = {
    REDIS_HOST                     = azurerm_redis_cache.main.hostname
    REDIS_PORT                     = azurerm_redis_cache.main.port
    REDIS_PASSWORD                 = azurerm_redis_cache.main.primary_access_key
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.main.instrumentation_key
    JWT_SECRET                     = "your-secure-jwt-secret-change-in-production"
    GIN_MODE                       = "release"
  }

  tags = var.common_tags
}

module "users_api" {
  source = "./modules/app-service"

  app_name            = "${var.app_name_prefix}-users"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  docker_image             = "users-api:latest"
  docker_registry_url      = "https://${azurerm_container_registry.main.login_server}"
  docker_registry_username = azurerm_container_registry.main.admin_username
  docker_registry_password = azurerm_container_registry.main.admin_password

  app_settings = {
    REDIS_HOST                     = azurerm_redis_cache.main.hostname
    REDIS_PORT                     = azurerm_redis_cache.main.port
    REDIS_PASSWORD                 = azurerm_redis_cache.main.primary_access_key
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.main.instrumentation_key
    SPRING_PROFILES_ACTIVE         = "docker"
    CACHE_TTL                      = "3600"
  }

  tags = var.common_tags
}

module "todos_api" {
  source = "./modules/app-service"

  app_name            = "${var.app_name_prefix}-todos"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  docker_image             = "todos-api:latest"
  docker_registry_url      = "https://${azurerm_container_registry.main.login_server}"
  docker_registry_username = azurerm_container_registry.main.admin_username
  docker_registry_password = azurerm_container_registry.main.admin_password

  app_settings = {
    REDIS_HOST                     = azurerm_redis_cache.main.hostname
    REDIS_PORT                     = azurerm_redis_cache.main.port
    REDIS_PASSWORD                 = azurerm_redis_cache.main.primary_access_key
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.main.instrumentation_key
    NODE_ENV                       = "production"
    CACHE_TTL                      = "1800"
  }

  tags = var.common_tags
}

module "frontend" {
  source = "./modules/app-service"

  app_name            = "${var.app_name_prefix}-frontend"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  docker_image             = "frontend:latest"
  docker_registry_url      = "https://${azurerm_container_registry.main.login_server}"
  docker_registry_username = azurerm_container_registry.main.admin_username
  docker_registry_password = azurerm_container_registry.main.admin_password

  app_settings = {
    VUE_APP_AUTH_API_URL              = "https://${var.app_name_prefix}-auth.azurewebsites.net"
    VUE_APP_USERS_API_URL             = "https://${var.app_name_prefix}-users.azurewebsites.net"
    VUE_APP_TODOS_API_URL             = "https://${var.app_name_prefix}-todos.azurewebsites.net"
    VUE_APP_CIRCUIT_BREAKER_TIMEOUT   = "5000"
    VUE_APP_CIRCUIT_BREAKER_THRESHOLD = "5"
    APPINSIGHTS_INSTRUMENTATIONKEY    = azurerm_application_insights.main.instrumentation_key
  }

  tags = var.common_tags
}

# Container Instance for Log Processor (background service)
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
      LOG_LEVEL      = "INFO"
    }
  }

  tags = var.common_tags
}