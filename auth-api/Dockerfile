# Build stage
FROM golang:1.25-alpine AS builder

# Install git and ca-certificates (needed for go modules)
RUN apk update && apk add --no-cache git ca-certificates && update-ca-certificates

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download
RUN go mod verify

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o main .

# Production stage
FROM alpine:latest

# Install ca-certificates and curl for HTTPS and health checks
RUN apk --no-cache add ca-certificates curl tzdata
RUN update-ca-certificates

# Create non-root user
RUN adduser -D -s /bin/sh appuser

WORKDIR /home/appuser

# Copy binary from builder stage
COPY --from=builder /app/main .
RUN chown appuser:appuser main

USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

CMD ["./main"]