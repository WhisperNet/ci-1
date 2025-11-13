#!/bin/bash

set +e  # Don't exit on error, we'll handle it manually

CONTAINER_NAME="demo-app"
HEALTH_ENDPOINT="http://127.0.0.1:3000/health"
MAX_RETRIES=5
RETRY_INTERVAL=2

echo "Checking container status..."

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "ERROR: Container $CONTAINER_NAME is not running!"
    exit 1
fi

echo "Container $CONTAINER_NAME is running."

# Check health endpoint - try multiple methods
echo "Checking health endpoint..."

for i in $(seq 1 $MAX_RETRIES); do
    # Method 1: Use docker exec to check from inside the container (most reliable)
    if docker exec "$CONTAINER_NAME" node -e "require('http').get('http://127.0.0.1:3000/health', (r) => {let data=''; r.on('data', d=>data+=d); r.on('end', ()=>{console.log(data); process.exit(r.statusCode === 200 ? 0 : 1)})})" 2>/dev/null; then
        echo "Health check passed!"
        docker exec "$CONTAINER_NAME" node -e "require('http').get('http://127.0.0.1:3000/health', (r) => {let data=''; r.on('data', d=>data+=d); r.on('end', ()=>{console.log(data)})})"
        exit 0
    fi
    
    # Method 2: Try curl from host (if available and accessible)
    if command -v curl > /dev/null 2>&1; then
        if curl -f -s "$HEALTH_ENDPOINT" > /dev/null 2>&1; then
            echo "Health check passed!"
            curl -s "$HEALTH_ENDPOINT" | jq '.' 2>/dev/null || curl -s "$HEALTH_ENDPOINT"
            exit 0
        fi
    fi
    
    echo "Attempt $i/$MAX_RETRIES failed. Retrying in ${RETRY_INTERVAL}s..."
    if [ $i -lt $MAX_RETRIES ]; then
        sleep $RETRY_INTERVAL
    fi
done

echo "ERROR: Health check failed after $MAX_RETRIES attempts!"
exit 1

