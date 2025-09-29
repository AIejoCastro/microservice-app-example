## Security

### Authentication & Authorization
- JWT-based authentication. Tokens issued by Auth API on `POST /login`.
- Downstream APIs (`users-api`, `todos-api`) expect `Authorization: Bearer <token>`.
- Shared `JWT_SECRET` must be consistent across services (dev) or centrally managed in prod.

### Secrets Management
- Local/dev: environment variables in compose.
- CI: use GitHub Secrets (`AZURE_CREDENTIALS`, `ARM_*`, `JWT_SECRET`).
- Azure: configure App Settings or integrate Azure Key Vault; never commit secrets.

### Network & Ports
- Local: single Docker network `app-network`. Only necessary ports exposed to host.
- Cloud: App Services exposed over HTTPS. Restrict SCM and enable HTTPS-only.

### Dependencies and Supply Chain
- Build per service with pinned platform versions in CI.
- Use `npm ci`, `go mod tidy`, `mvn` with reproducible builds where possible.

### Hardening Recommendations
- Enforce minimal base images, drop root where applicable.
- Configure rate limits and CORS on APIs if exposed publicly.
- Configure Redis with authentication in non-dev environments (Terraform wires password to apps).


