## Log Message Processor (Python)

### Summary
Background worker consuming Redis channel messages produced by TODOs API. Prints or forwards messages for processing; packaged for Azure Container Apps.

### Configuration
- `REDIS_HOST`, `REDIS_PORT`, `REDIS_CHANNEL`
- Optional: `ZIPKIN_URL`, `LOG_LEVEL`

### Local Run
```bash
pip3 install -r requirements.txt
REDIS_HOST=127.0.0.1 REDIS_PORT=6379 REDIS_CHANNEL=logs python3 main.py
```

### Docker
- Image name: `log-message-processor:latest`
- Runs without ports; depends on Redis

### Cloud
- Deployed as Azure Container App with CPU 0.5 and 1Gi memory, pulling image from ACR. Secrets supplied via environment variables.


