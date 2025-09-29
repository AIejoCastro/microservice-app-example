## TODOs API (Node.js)

### Summary
CRUD over in-memory TODOs. Publishes create/delete events to Redis channel for the log processor. Runs on 8082.

### Endpoints
- `GET /todos`
- `POST /todos`
- `DELETE /todos/:taskId`

### Configuration
- `TODO_API_PORT`
- `JWT_SECRET`
- `REDIS_HOST`, `REDIS_PORT`, `REDIS_CHANNEL`

### Local Run
```bash
npm install
JWT_SECRET=PRFT TODO_API_PORT=8082 npm start
```

### Docker
- Image name: `todos-api:latest`
- Compose env includes Redis and `CACHE_TTL`

### Build & Test (CI)
- Node 16/18; `npm ci && npm run build` (best-effort) and `npm test` if present


