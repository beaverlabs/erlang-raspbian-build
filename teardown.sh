#!/bin/bash

set -e

SE_CONTAINER_NAME=beaverlabs/erlixir
SE_CONTAINER_EXISTS=$(docker image ls | grep "^$SE_CONTAINER_NAME")

if [[ "$SE_CONTAINER_EXISTS" == "$SE_CONTAINER_NAME" ]]; then
  echo "Destroying container..."
  docker image rm $SE_CONTAINER_NAME
fi

echo "Done!"
