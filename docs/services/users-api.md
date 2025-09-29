## Users API (Java Spring Boot)

### Summary
Provides user data. Requires a valid JWT (from Auth API). Uses Redis for cache-aside. Runs on port 8083.

### Endpoints
- `GET /users` → list all users
- `GET /users/:username` → fetch single user

### Configuration
- `SERVER_PORT`: port (compose binds `8083:8083`)
- `JWT_SECRET`: shared JWT secret
- `REDIS_HOST`, `REDIS_PORT`: Redis cache
- `SPRING_PROFILES_ACTIVE=docker` in compose

### Local Run
```bash
./mvnw clean install
JWT_SECRET=PRFT SERVER_PORT=8083 java -jar target/users-api-0.0.1-SNAPSHOT.jar
```

### Docker
- Image name: `users-api:latest`
- Compose env: `CACHE_TTL`, Redis vars

### Build & Test (CI)
- Java 11 Temurin; `mvn clean compile` and `mvn test`


