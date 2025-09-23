variable "app_name" {
  description = "Name of the web app"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "service_plan_id" {
  description = "ID of the App Service Plan"
  type        = string
}

variable "docker_image" {
  description = "Docker image name for the app (without registry URL)"
  type        = string
}

variable "docker_registry_url" {
  description = "Docker registry URL"
  type        = string
}

variable "docker_registry_username" {
  description = "Docker registry username"
  type        = string
}

variable "docker_registry_password" {
  description = "Docker registry password"
  type        = string
  sensitive   = true
}

variable "app_settings" {
  description = "App settings for the web app"
  type        = map(string)
  default     = {}
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for the app"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {}
}