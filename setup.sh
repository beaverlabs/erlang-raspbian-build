#!/bin/bash

set -e

SE_CONTAINER_NAME=beaverlabs/erlixir

if docker image ls | grep -q "^$SE_CONTAINER_NAME"; then
  echo "Container already exists!"
else
  echo "Creating container..."
  docker build -t $SE_CONTAINER_NAME .
fi

echo "Done!"
