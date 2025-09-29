## Frontend (Vue.js)

### Summary
SPA that communicates with Auth, Users, and TODOs APIs. Includes a client-side circuit breaker.

### Configuration
- `PORT`
- `VUE_APP_AUTH_API_URL`, `VUE_APP_USERS_API_URL`, `VUE_APP_TODOS_API_URL`
- `VUE_APP_CIRCUIT_BREAKER_TIMEOUT`, `VUE_APP_CIRCUIT_BREAKER_THRESHOLD`

### Local Run
```bash
npm install
npm run dev
```

### Docker
- Image name: `frontend:latest`
- Compose port: `8080:8080`
- Env wired to the backend container addresses for local

### Build & Test (CI)
- Node 14/16/18 (setup matrix), `npm ci && npm run build`, optional unit tests `npm run test:unit`


