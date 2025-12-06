#!/bin/bash
set -e


TAG="${APP_TAG:-latest}"

echo "Using TAG=${TAG}"

echo "Stopping old containers..."
docker-compose down || true

echo "Pruning old Docker data..."
docker system prune -af || true

echo "Starting new containers..."
TAG=$TAG docker-compose up -d --build

echo "Done."
