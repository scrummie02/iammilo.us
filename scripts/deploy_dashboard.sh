#!/bin/bash
# Deploy updated MILO Fleet Dashboard via Portainer API
# Author: MILO - Mechanical Intelligent Learning Operator
#
# This script pushes the updated dashboard HTML to the milo_blog container via Portainer API.
# It requires:
# 1. SSH access to 192.168.200.220
# 2. Portainer API access with the provided API key

PORTAINER="http://192.168.200.220:9000"
PTR_KEY="ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
CONTAINER="milo_blog"
ENDPOINT=7

# Read the updated dashboard HTML
B64_DATA=$(cat /home/dain/.openclaw/workspace/scripts/refresh_dashboard_update.html | base64 -d)

echo "Pushing dashboard HTML to Portainer API..."

# Push HTML to Portainer API (POST to /docker/containers/:CONTAINER/exec)
RESPONSE=$(curl -s -X POST \
    -H "X-API-Key: $PTR_KEY" \
    -H "Content-Type: application/json" \
    -H "AttachStdout: true" \
    -H "AttachStderr: true" \
    -H "Tty: false" \
    -d "{\"data\": \"$B64_DATA\", \"type\": \"stream\", \"read_timeout\": 30000}" \
    "$PORTAINER/api/endpoints/$ENDPOINT/docker/containers/$CONTAINER/exec" 2>&1)

if [ $? -eq 0 ]; then
    echo "Dashboard HTML pushed successfully to Portainer API"
    echo "Response: $RESPONSE"
else
    echo "Failed to push dashboard HTML"
    echo "Response: $RESPONSE"
    exit 1
fi

# Start the container with the HTML
echo "Starting container milo_blog..."
START_RESPONSE=$(curl -s -X POST \
    -H "X-API-Key: $PTR_KEY" \
    -H "Content-Type: application/json" \
    -H "Detach: false" \
    -H "Tty: false" \
    -d "{\"data\": \"$B64_DATA\", \"type\": \"stream\", \"read_timeout\": 30000}" \
    "$PORTAINER/api/endpoints/$ENDPOINT/docker/exec/$RESPONSE/start" 2>&1)

if [ $? -eq 0 ]; then
    echo "Container started successfully"
    echo "Status: $START_RESPONSE"
else
    echo "Failed to start container"
    echo "Response: $START_RESPONSE"
    exit 1
fi

echo "Dashboard deployed successfully at 192.168.200.220:9000"
