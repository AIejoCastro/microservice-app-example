resource "azurerm_linux_web_app" "main" {
  name                = var.app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  site_config {
    # Configuración de contenedor (para stacks estándar, OJO: algunos providers ya no soportan docker_image_name aquí)
    application_stack {
      docker_image_name   = var.docker_image
      docker_registry_url = var.docker_registry_url
    }

    # Health check configuration (Circuit Breaker Pattern)
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5

    # Always on para mejor performance
    always_on = true

    # Detailed error logging (sí es válido aquí)
    detailed_error_logging_enabled = true
  }

  # Logs de la aplicación
  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  # App settings incluyendo credenciales del registry
  app_settings = merge(var.app_settings, {
    "DOCKER_REGISTRY_SERVER_URL"          = var.docker_registry_url
    "DOCKER_REGISTRY_SERVER_USERNAME"     = var.docker_registry_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = var.docker_registry_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE"     = "true"
  })

  # Identity para acceder a otros recursos de Azure
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}


# Auto-scaling rules (Autoscaling Pattern)
resource "azurerm_monitor_autoscale_setting" "main" {
  count               = var.enable_autoscaling ? 1 : 0
  name                = "${var.app_name}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = var.service_plan_id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = var.service_plan_id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = var.service_plan_id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  tags = var.tags
}