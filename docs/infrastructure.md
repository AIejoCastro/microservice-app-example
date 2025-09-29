## Infrastructure (Terraform on Azure)

### Overview
Terraform under `terraform/` provisions Azure resources:
- Resource Group
- Azure Container Registry (ACR)
- App Service Plan (Linux)
- Four Linux Web Apps (auth, users, todos, frontend)
- Azure Redis Cache
- Application Insights
- Container App Environment and one Container App for `log-message-processor`

### Key Files
- `terraform/main.tf`: root resources and four `modules/app-service` instantiations
- `terraform/modules/app-service`: defines an `azurerm_linux_web_app` and optional autoscaling on the Plan

### Variables (selected)
- `resource_group_name`, `location`, `container_registry_name`, `app_service_plan_name`, `app_name_prefix`, `redis_cache_name`, `app_insights_name`, `enable_autoscaling`, `common_tags`

### App Settings (per Web App)
Each module injects settings such as docker registry credentials, Redis host/port/password, and Application Insights key. Frontend also receives `VUE_APP_*` URLs bound to the Azure Web App hostnames.

### Container App (Log Processor)
Configured with 0.5 CPU / 1Gi, environment variables for Redis and App Insights, and pulls from ACR.

### Backend State
Github Actions initializes Terraform with remote state (example storage RG/account/container). Adjust to your state backend.

### Apply
CI performs `terraform plan` on PRs to `master` and applies on `master` with approval. For local:
```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```


