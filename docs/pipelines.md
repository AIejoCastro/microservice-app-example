## CI/CD Pipelines (GitHub Actions)

### Development Pipeline
Workflow: `.github/workflows/development-pipeline.yml`

Triggers:
- Push to `develop` or `master` for service paths; PRs to `master`; manual dispatch

Jobs:
1) Build and Test
   - Matrix across: `auth-api`, `users-api`, `todos-api`, `frontend`, `log-message-processor`
   - Uses composite action to setup language toolchains
   - Frontend: installs build tools, `npm install --legacy-peer-deps`
   - Builds with `scripts/build-service.sh <service>`
   - Tests with `scripts/test-service.sh <service>`

2) Build Docker Images (on `master` or `develop`)
   - Azure login via `AZURE_CREDENTIALS`
   - Docker login to ACR `microappregistry.azurecr.io`
   - Runs `scripts/build-and-push-images.sh` to push `:latest` tags

3) Deploy to Azure (only on `master`)
   - Azure login
   - Runs `scripts/deploy-to-azure.sh production` to point Web Apps at latest images and restart
   - Example of per-app settings shown for `users-api`

### Infrastructure Pipeline
Workflow: `.github/workflows/infraestructure-pipeline.yml`

Triggers:
- Push/PR to `master` affecting `terraform/**`; manual dispatch

Jobs:
1) Terraform Validate
   - `terraform fmt -check`, `terraform init -backend=false`, `terraform validate`

2) Terraform Plan
   - Azure login using service principal env vars
   - Registers required Azure providers
   - `terraform init` with remote backend settings
   - `terraform plan -out=tfplan` and uploads the plan artifact
   - Comments plan on PRs

3) Terraform Apply (on `master` and with workflow_dispatch)
   - Azure login and provider registration
   - Downloads plan, runs `terraform apply -auto-approve tfplan`

### Secrets and Env
- `AZURE_CREDENTIALS`: JSON for `azure/login`
- `ARM_SUBSCRIPTION_ID`, `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`
- `JWT_SECRET` and other app settings as applicable


