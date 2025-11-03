#!/bin/bash
echo "Stopping old container (if exists)..."
docker stop react-app-container || true
docker rm react-app-container || true

echo "Starting new container..."
docker run -d -p 80:80 --name react-app-container react-app
echo "Container Ready!"
docker ps
