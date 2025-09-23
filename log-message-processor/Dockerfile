# Production stage (single stage since Python doesn't need compilation)
FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for better layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Create non-root user
RUN groupadd -r python && useradd -r -g python python
RUN chown -R python:python /app
USER python

# No health check needed for background processor
# But we can add a simple one
HEALTHCHECK --interval=60s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import redis; r=redis.Redis(host='${REDIS_HOST:-redis}', port=${REDIS_PORT:-6379}); r.ping()" || exit 1

# Set Python path
ENV PYTHONPATH=/app

CMD ["python", "main.py"]