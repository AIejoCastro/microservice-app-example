## Auth API (Go)

### Summary
Issues JWT tokens via `POST /login` for demo users. Integrates with Users API and Redis for cache-aside. Runs on port 8000 by default in docker-compose.

### Endpoints
- `POST /login` → returns `{ token: <jwt> }` for valid credentials.

### Configuration
- `AUTH_API_PORT`: service port.
- `USERS_API_ADDRESS`: base URL for Users API.
- `JWT_SECRET`: shared secret for signing JWTs.
- `REDIS_HOST`, `REDIS_PORT`: Redis cache (compose: `redis:6379`).

### Local Run
```bash
JWT_SECRET=PRFT AUTH_API_PORT=8000 USERS_API_ADDRESS=http://127.0.0.1:8083 go run .
```

### Docker
- Image name: `auth-api:latest`
- Compose port: `8000:8000`
- Env in compose: `GIN_MODE=release`, `JWT_SECRET`, Redis vars

### Build & Test (CI)
- Built with Go 1.21 in CI script
- `go mod download && go build -o main .`
- Tests: `go test ./...` (none by default)


