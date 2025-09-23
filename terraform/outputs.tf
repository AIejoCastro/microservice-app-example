output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "container_registry_login_server" {
  description = "Login server for the container registry"
  value       = azurerm_container_registry.main.login_server
}

output "redis_hostname" {
  description = "Redis cache hostname"
  value       = azurerm_redis_cache.main.hostname
  sensitive   = true
}

output "app_urls" {
  description = "URLs of the deployed applications"
  value = {
    frontend   = "https://${module.frontend.app_url}"
    auth_api   = "https://${module.auth_api.app_url}"
    users_api  = "https://${module.users_api.app_url}"
    todos_api  = "https://${module.todos_api.app_url}"
  }
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}