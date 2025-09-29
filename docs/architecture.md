## System Architecture

This project is a microservices-based TODO application composed of independent services, a single-page frontend, shared cache, and optional monitoring stack. Services communicate over HTTP and Redis pub/sub for async logging.

### Components
- Auth API (`auth-api`, Go): issues JWTs via `POST /login` using static demo users. Uses Redis for cache-aside.
- Users API (`users-api`, Java Spring Boot): exposes user data via `GET /users` and `GET /users/:username`. Uses Redis cache-aside.
- TODOs API (`todos-api`, Node.js): CRUD over in-memory TODOs and publishes create/delete events to Redis channel.
- Frontend (`frontend`, Vue.js): SPA consuming the three APIs. Implements a circuit breaker in the client.
- Log Message Processor (`log-message-processor`, Python): background worker consuming Redis channel messages.
- Redis: shared cache and pub/sub bus.
- Monitoring (optional): Prometheus, Grafana, cAdvisor; plus Azure Application Insights in cloud.

### Runtime Topology
- Local (docker-compose): All services run in a single Docker network `app-network` with exposed ports:
  - Redis: 6379
  - Auth API: 8000
  - Users API: 8083
  - TODOs API: 8082
  - Frontend: 8080

- Cloud (Azure):
  - One Resource Group
  - Azure Container Registry (ACR)
  - App Service Plan (Linux)
  - Four Linux Web Apps (auth, users, todos, frontend) pulling images from ACR
  - Azure Redis Cache (Basic) with `allkeys-lru`
  - Application Insights instance
  - Azure Container App for the log message processor

### Data and Control Flows
1) Authentication: Frontend calls Auth API -> returns JWT. JWT used to call Users and TODOs APIs.
2) Users: Frontend -> Users API -> returns users; cache-aside through Redis.
3) TODOs: Frontend -> TODOs API; on create/delete, API publishes message to Redis channel `logs` (or configured) -> Log Processor consumes and processes.
4) Observability: Prometheus scrapes exporters (if configured); Grafana dashboards; App Insights for cloud apps.

### Resilience Patterns
- Cache-aside with Redis for `auth-api`, `users-api`, and `todos-api` (per docker-compose env).
- Client-side circuit breaker in the Frontend with configurable timeout and threshold via `VUE_APP_CIRCUIT_BREAKER_*`.

### Images and Deployment
- Images are built per service and pushed to ACR: `microappregistry.azurecr.io/<service>:latest`.
- Web Apps configured to pull `latest` tag; Container App updated separately for the log processor.

### Security
- JWT shared `JWT_SECRET` across components in dev. In production, store in secure secrets (GitHub Secrets, Azure App Settings/Key Vault).


