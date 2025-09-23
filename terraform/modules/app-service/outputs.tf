output "app_url" {
  description = "URL of the deployed app"
  value       = azurerm_linux_web_app.main.default_hostname
}

output "app_id" {
  description = "ID of the web app"
  value       = azurerm_linux_web_app.main.id
}

output "app_name" {
  description = "Name of the web app"
  value       = azurerm_linux_web_app.main.name
}