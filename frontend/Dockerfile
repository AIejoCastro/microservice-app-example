# Build stage
FROM node:16-alpine as build-stage

WORKDIR /app
COPY package*.json ./

# Instalar dependencias con --legacy-peer-deps para Vue 2
RUN npm install --legacy-peer-deps

COPY . .
RUN npm run build

# Production stage
FROM nginx:stable-alpine as production-stage

# Instalar curl para health check
RUN apk --no-cache add curl

COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

# Health check en puerto 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
