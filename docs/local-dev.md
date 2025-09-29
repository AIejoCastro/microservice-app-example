## Local Development

### Prerequisites
- Docker and Docker Compose
- Node.js LTS, Go 1.21, Java 11, Python 3.9 (for running/building outside of Docker)

### Quick Start (Docker Compose)
```bash
docker compose up -d --build
# or: docker-compose up -d --build
```

Services will be available at:
- Frontend: http://localhost:8080
- Auth API: http://localhost:8000
- Users API: http://localhost:8083
- TODOs API: http://localhost:8082
- Redis: localhost:6379

Stop and clean:
```bash
docker compose down -v
```

### Environment Variables (compose highlights)
- Auth API: `JWT_SECRET`, `REDIS_HOST`, `REDIS_PORT`, `GIN_MODE`
- Users API: `SPRING_PROFILES_ACTIVE`, `REDIS_*`, `CACHE_TTL`
- TODOs API: `NODE_ENV`, `REDIS_*`, `CACHE_TTL`
- Frontend: `VUE_APP_*` URLs and circuit breaker knobs

### Developer Workflow
- Build a single service locally:
  ```bash
  cd <service>
  ../scripts/build-service.sh <service>
  ../scripts/test-service.sh <service>
  ```
- Build and push all images to ACR (CI mirrors this):
  ```bash
  ./scripts/build-and-push-images.sh
  ```

### Troubleshooting
- Ports already in use: stop conflicting processes or change host mappings.
- Frontend failing to reach APIs: confirm `VUE_APP_*` URLs and that APIs are up.
- Redis connection errors: ensure `redis` container is healthy and networked.


