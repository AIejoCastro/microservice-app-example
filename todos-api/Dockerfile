# Build stage
FROM node:16-alpine as build-stage

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application (if there's a build step)
RUN npm run build 2>/dev/null || echo "No build script found, continuing..."

# Production stage
FROM node:16-alpine as production-stage

# Install curl for health checks
RUN apk --no-cache add curl

WORKDIR /app

# Copy node_modules and built app from build stage
COPY --from=build-stage /app/node_modules ./node_modules
COPY --from=build-stage /app .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
RUN chown -R nodejs:nodejs /app
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8082/health || exit 1

EXPOSE 8000

CMD ["npm", "start"]