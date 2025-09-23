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
  description = "Docker image for the app"
  type        = string
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

variable "create_autoscale" {
  description = "Whether to create autoscale setting (only one per App Service Plan)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {}
}