#!/bin/bash

set -e

CONTAINER_NAME="demo-app"
HEALTH_ENDPOINT="http://localhost:3000/health"
MAX_RETRIES=5
RETRY_INTERVAL=2

echo "Checking container status..."

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "ERROR: Container $CONTAINER_NAME is not running!"
    exit 1
fi

echo "Container $CONTAINER_NAME is running."

# Check health endpoint
echo "Checking health endpoint: $HEALTH_ENDPOINT"

for i in $(seq 1 $MAX_RETRIES); do
    if curl -f -s "$HEALTH_ENDPOINT" > /dev/null 2>&1; then
        echo "Health check passed!"
        curl -s "$HEALTH_ENDPOINT" | jq '.' || curl -s "$HEALTH_ENDPOINT"
        exit 0
    else
        echo "Attempt $i/$MAX_RETRIES failed. Retrying in ${RETRY_INTERVAL}s..."
        if [ $i -lt $MAX_RETRIES ]; then
            sleep $RETRY_INTERVAL
        fi
    fi
done

echo "ERROR: Health check failed after $MAX_RETRIES attempts!"
exit 1

