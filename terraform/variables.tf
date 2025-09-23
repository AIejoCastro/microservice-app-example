variable "resource_group_name" {
  description = "microservicerg"
  type        = string
  default     = "microservice-app-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "Canada Central"
}

variable "app_name_prefix" {
  description = "Prefix for all application resources"
  type        = string
  default     = "microapp"
}

variable "container_registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "microappregistry"
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
  default     = "microapp-plan"
}

variable "redis_cache_name" {
  description = "Name of the Redis Cache"
  type        = string
  default     = "microapp-redis"
}

variable "app_insights_name" {
  description = "Name of the Application Insights"
  type        = string
  default     = "microapp-insights"
}

variable "environment" {
  description = "Environment (staging, production)"
  type        = string
  default     = "production"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "microservice-app"
    ManagedBy   = "terraform"
  }
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for app services"
  type        = bool
  default     = true
}